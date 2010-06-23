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
<%@ include file="jsp/declares.jsp" %>
<%@ include file="jsp/header.jsp" %>

<%
		if (!key.equals("empty")) {

			try {
				users = (List<MeetupUser>) query.execute(key);

				//TRY TO FIND USERINFO DATA
				Query userQuery = pm.newQuery(UserInfo.class);
				userQuery.setFilter("user_id == idParam");
				userQuery.declareParameters("String idParam");
				try {
					List<UserInfo> profiles = (List<UserInfo>) userQuery.execute(users.get(0).getID());
					if (profiles.size() > 0) {
					
%>
<p><%=users.get(0).getName()%>
<a href ="/logout?callback=">LOGOUT</a></p>

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
User Preferences - <%=users.get(0).getName()%>
<br><br>
Recieving Notifications from the following topics:
<br>
<%
	String[] groups = profiles.get(0).getGroupArray();
	if (groups.length > 0) {
		String apiParam = groups[0];
		for (int i = 1; i < groups.length; i++) {
			apiParam = apiParam + "," + groups[i];
		}
		Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
		APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/containers/?container_id="+apiParam);
		scribe.signRequest(APIrequest,accessToken);
		APIresponse = APIrequest.send();
		JSONObject json = new JSONObject();
		JSONArray results;

		//Request APItest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/container/654/alert");
		//scribe.signRequest(APItest,accessToken);
		//Response APIres = APItest.send();
		//System.out.println(APIres.getBody());
		
		try {
			json = new JSONObject(APIresponse.getBody());
			results = json.getJSONArray("results");
			for (int j = 0; j < results.length(); j++) {
%>
-<b><a href="/Group?<%=results.getJSONObject(j).getString("id")%>"><%=results.getJSONObject(j).getString("urlname") %> </a></b>
&nbsp <a href="/setprefs?id=<%=users.get(0).getID()%>&callback=UserPrefs.jsp&group=<%=results.getJSONObject(j).getString("id")%>&action=remove">Remove</a>
<br>
<%
			}
		} catch (JSONException j) {

		}
	}

%>
<br>
Change your email address?<br>
<form name="email" action="/setprefs">
<input type="text" name="email" value="<%= profiles.get(0).getEmail() %>"></input> Email Address<br>
<br>
How far would you travel for a meetup?<br>
<input type="text" name="distance" value="<%= profiles.get(0).getDistance() %>" size="4"/> miles
<br>
<br>
What times would you like to recieve notifications? <br>
<input type="checkbox" name="time" value="morning" /> Morning
<input type="checkbox" name="time" value="afternoon" /> Afternoon
<input type="checkbox" name="time" value="night" /> Night
<br>
<br>
<input type="hidden" name="id" value="<%= users.get(0).getID()%>" />
<input type="hidden" name="callback" value="/" />
<input type="submit" value="Change Preferences"></input>
</form>
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

<%
					}
				} finally {
					userQuery.closeAll();
				}
			} finally {
				query.closeAll();
			}
		}
%>

</div>

</body>
</html>
