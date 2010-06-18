<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.UserInfo" %>
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

<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/header.jsp" %>
<%
		String c_id = "";
		
		if (request.getQueryString() != null) {
			c_id = request.getQueryString();
		}


		if (!key.equals("empty")) {
			try {
				users = (List<MeetupUser>) query.execute(key);
					
%>


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
	APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/events/?status=upcoming&container_id="+c_id+"&page=20&fields=rsvp_count");
	scribe.signRequest(APIrequest,accessToken);
	APIresponse = APIrequest.send();
	JSONObject json = new JSONObject();
	JSONArray results;
	try {
		json = new JSONObject(APIresponse.getBody());
		results = json.getJSONArray("results");
%>
										<div id="mn_geoListHeader">
											<span><b>Upcoming Events</b></span>
<br><%= results.getJSONObject(0).getJSONObject("container").getString("name") %> <br>

<%
		Query userQuery = pm.newQuery(UserInfo.class);
		userQuery.setFilter("user_id == idParam");
		userQuery.declareParameters("String idParam");
		try {
			List<UserInfo> profiles = (List<UserInfo>) userQuery.execute(users.get(0).getID());
			if (profiles.size() > 0) {
				String[] groups = profiles.get(0).getGroupArray();
				if (profiles.get(0).isMember(c_id)) {
%>
<a href="/UserPrefs.jsp">You recieve notifications from this group!</a>
<%
				}
				else {
%>
<a href="/setprefs?id=<%=users.get(0).getID()%>&action=add&callback=<%=request.getRequestURI()+"?"+request.getQueryString()%>&group=<%=c_id %>">Recieve notifications from this group</a>
<%
				}
			}
		} finally {
			userQuery.closeAll();
		}

%>

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
<%@ include file="jsp/footer.jsp" %>

<%
			} finally {
				query.closeAll();
			}
		}
%>
</body>
</html>
