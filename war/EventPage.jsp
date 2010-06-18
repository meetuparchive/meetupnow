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
<%@ page import="java.util.Calendar" %>


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
		String ev_id = "";
		
		if (request.getQueryString() != null) {
			ev_id = request.getQueryString();
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
<a href ="/logout?callback=">LOGOUT</a></p>

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
										<div id="mn_geoListHeader">

										</div><!-- mn_geoListHeader -->
<%
if (users.iterator().hasNext()) {
	Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
	Request APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/events/?event_id="+ev_id);
	scribe.signRequest(APIrequest,accessToken);
	Response APIresponse = APIrequest.send();
	JSONObject json = new JSONObject();
	JSONArray results;
	try {
		json = new JSONObject(APIresponse.getBody());
		results = json.getJSONArray("results");
		if (results.length() == 1) {
			JSONObject item = results.getJSONObject(0);
			Calendar cal = Calendar.getInstance();
			cal.setTimeInMillis(Long.parseLong(item.getString("time")));
%>
<%=item.getJSONObject("container").getString("name") %> Event #<%=ev_id%>
<br>
<%=cal.getTime().toLocaleString() %>
<br><br>
Location: <%=item.getString("city") %>, 
<%
			try{
%>
<%=item.getString("state") %>
<%		
			} catch (JSONException j) {
%>			
<%=item.getString("country").toUpperCase() %>
<%
			}
%>
&nbsp - &nbsp <%=item.getString("venue_name") %>
<br>
<img src="http://maps.google.com/maps/api/staticmap?zoom=14&size=300x200&maptype=roadmap&markers=color:blue|size:large|<%=item.getString("lat")+","+item.getString("lon")%>&sensor=false"/>
<br><br>
Description: <%=item.getString("description") %>
<%

		}
		else {

		}

	} catch (Exception j) {
			
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
<%@ include file="jsp/footer.jsp" %>
<%
			} finally {
				query.closeAll();
			}
		}
%>

</body>
</html>
