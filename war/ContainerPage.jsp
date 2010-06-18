<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
</head>
<body id="meetupNowBody">
	
<div id="mew_header">
	<div id="mew_headerBody">
		<div id="mew_logo">
			<a href="http://www.meetup.com/everywhere">
				<img src="images/meetup_ew.png" alt="Meetup" style="width: auto !important; height: auto !important">
			</a>
		</div><!-- mew_logo -->
		<div id="mew_userNav">
<%

		String c_id = "";
		
		if (request.getQueryString() != null) {
			c_id = request.getQueryString();
		}

		String key = "empty";
    		javax.servlet.http.Cookie[] cookies = request.getCookies();
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
%>
<a href="/oauth">Log In</a>
<%
		} else {
			//FIND USER			

			Properties prop = new Properties();
			prop.setProperty("consumer.key","12345");
			prop.setProperty("consumer.secret","67890");
			Scribe scribe = new Scribe(prop);
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query query = pm.newQuery(MeetupUser.class);
			query.setFilter("accToken == accTokenParam");
			query.declareParameters("String accTokenParam");
			try {
				List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
					
%>
<p><%=users.get(0).getName()%>
<a href ="/logout?callback=<%=request.getRequestURI()+"?"+request.getQueryString()%>">LOGOUT</a></p>

</div>
	</div><!-- mew_headerBody -->
</div><!-- mew_header -->

<div id="mn_page">
	<div id="mn_pageBody">
		<div id="mn_context">
			<div id="mn_document">
				<div id="mn_box">
					<div class="d_box">
						<div class="d_boxBody">
							<div class="d_boxHead">
								
							</div>
							<div class="d_boxSection">
								<div id="d_boxContent">
									<div id="mn_geoListContext">
<%
if (users.iterator().hasNext()) {
	Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
	Request APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/events/?status=upcoming&container_id="+c_id+"&page=20&fields=rsvp_count");
	scribe.signRequest(APIrequest,accessToken);
	Response APIresponse = APIrequest.send();
	JSONObject json = new JSONObject();
	JSONArray results;
	try {
		json = new JSONObject(APIresponse.getBody());
		results = json.getJSONArray("results");
%>
										<div id="mn_geoListHeader">
											<span><b>Upcoming Events</b></span>
<br><%= results.getJSONObject(0).getJSONObject("container").getString("name") %> <br>
<a href="/setprefs?id=<%=users.get(0).getID()%>&callback=UserPrefs.jsp<%="?"+request.getQueryString()+"&group="+c_id %>">Recieve notifications from this group</a>
&nbsp &nbsp <a href="/CreateEvent.jsp?<%=c_id%>">Create A New Event</a>
											<br><br>
										</div><!-- mn_geoListHeader -->
<%
		for (int j = 0; j < results.length(); j++) {
			JSONObject item = results.getJSONObject(j);
%>
<span class="mn_geoListItem"><p><b></b> <%= (item.getString("city")+", "+item.getString("country").toUpperCase()) %> 
<%
			try {
%>
&nbsp - &nbsp <%=item.getString("venue_name")%>	
<%
			} catch (Exception e) {}
%>		
</p>
<p> &nbsp <%= (item.getString("rsvp_count")+" people are in.") %> 
<%
			if (users.get(0).isAttending(item.getString("id"))) {
%>
&nbsp &nbsp You're In!
<%
			}
			else {
%>
&nbsp &nbsp <a href="<%= "/EventRegister?id="+item.getString("id")+"&callback="+request.getRequestURI()+"?"+request.getQueryString() %>">I'm In</a> </p>
<%						
			}
%>
</span><br>
<%
		}
	} catch (JSONException j) {
			
	}
}
%>

										<div id="mn_geoListFooter">
										
										</div><!-- mn_geoListFooter -->
									</div><!-- mn_geoListContext -->
								</div><!-- d_boxContent -->
							</div><!-- d_boxSection -->
						</div><!-- d_boxBody -->
					</div><!-- d_box -->
				</div><!-- mn_box -->
			</div><!-- mn_document -->
		</div><!-- mn_context -->
	</div><!-- mn_pageBody -->
</div><!-- mn_page -->
<a href="/">Home</a><br>
<%
			} finally {
				query.closeAll();
			}
		}
%>
</body>
</html>
