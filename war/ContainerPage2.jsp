<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="meetupnow.UserInfo" %>

<%@ page import="java.io.IOException" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="meetupnow.OAuthServlet" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript" src="/js/container.js"></script>
	<script type="text/javascript">

		
		function loadEvents(){
		<%@ include file="jsp/cookie.jsp" %>
		<%@ include file="jsp/declares.jsp" %>

		<%

		String c_id = "";
		
		if (request.getQueryString() != null) {
			c_id = request.getQueryString();
		} else {
			c_id = "654";
		}

		if (!key.equals("empty")) {
			try {
				users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					API_URL = "http://api.meetup.com/ew/events/?status=upcoming&container_id="+c_id+"&page=20&fields=rsvp_count";
					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					JSONObject json = new JSONObject();
					JSONArray results;
					try {
						json = new JSONObject(APIresponse.getBody());
						results = json.getJSONArray("results");
						for (int i = 0; i < results.length(); i++) {
							if (users.get(0).isAttending(results.getJSONObject(i).getString("id"))) {
								results.getJSONObject(i).put("attending", "yes");
							} else {
								results.getJSONObject(i).put("attending", "no");
							}				
						}
					}
					catch (JSONException j){

					}
					%>var data = <%=json.toString()%><%
				}
			}
			finally {

			}
		}
		else {

			API_URL = "http://api.meetup.com/ew/events?status=upcoming&radius=25.0&order=time&offset=0&format=json&page=20&fields=rsvp_count&container_id=654&sig_id=12219924&sig=d69e5f28dcdac2af44220c77b3545988";
			APIrequest = new Request(Request.Verb.GET, API_URL);
			APIresponse = APIrequest.send();
			%>var data = <%=APIresponse.getBody().toString()%><%
	
		}
		%>
			use_everywhere(data);
		}

	</script>
</head>
<body id="meetupNowBody" onload="loadEvents()">











	
<%@ include file="jsp/header.jsp" %>

<div id="mn_page">
	<div id="mn_pageBody">
		<div id="mn_context">
			<div id="mn_document">
				<div id="mn_box">
					<div class="d_box">
						<div class="d_boxBody">
							
							<div class="d_boxSection">
								<div id="d_boxContent">
									<div id="d_boxContentRight">
										<div id="mn_description">
											<span class="subtitle"></span>
											<span class="subtitle">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua?</span>
											<span class="title">Lorem ipsum!</span>
											<span class="button_start">Get Started!</span>
										</div><!-- mn_description -->
										<div id="mn_eventDescription">
												<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
										</div><!-- mn_eventDescription -->

									</div><!-- d_boxContentRight -->
									
									
									<div id="d_boxContentLeft">
										<div class="map_context">
											<span class="map_title title">Events for <script> data.results[0].container.name </script></span>
										




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
											<div id="map_canvasContainer">
												<div id="map_canvas">
										
												</div><!-- map_canvas -->
											</div><!-- map_canvasContainer -->
										</div><!-- map_context -->
										<div id="mn_geoListContext">
											<div id="mn_geoListHeader">
												<span>Today in Sports<span>
											</div><!-- mn_geoListHeader -->
											
											<div id="mn_geoListFooter">
										
											</div><!-- mn_geoListFooter -->
										</div><!-- mn_geoListContext -->
									</div><!-- d_boxContentLeft -->
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
</body>
</html>
