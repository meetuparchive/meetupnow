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
<div id="wrapper">
	<div id="wrapperContent">
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
		
		<div id="contentRight">
			<span class="title"><%=users.get(0).getName()%></span>
		</div> <!-- end #contentRight -->
		<div id="contentLeft">
			<div id="contentLeftContext">
				<form name="email" action="/setprefs">
				

				
				<span class="title">Preferences</span>
				<br>
				<span class="heading">My Favorite Topics:</span>
				
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
				
				<span class="options"> &nbsp - &nbsp <b><a href="/Group?<%=results.getJSONObject(j).getString("id")%>"><%=results.getJSONObject(j).getString("urlname") %> </a></b>
				&nbsp <a href="/setprefs?id=<%=users.get(0).getID()%>&callback=UserPrefs.jsp&group=<%=results.getJSONObject(j).getString("id")%>&action=remove">Remove</a> </span>
				<br>
				
				<%
							}
						} catch (JSONException j) {

						}
					}

				%>
				
				<span class="options"><a href="/search.jsp">Search for more topics</a></span><br>
				<span class="options">
				<input type="text" name="zip" size="6"></input> Zip Code
				&nbsp
				<input type="text" name="distance" value="<%= profiles.get(0).getDistance() %>" size="4"/> Max Travelling Distance (miles)
				</span>
				<br>
				<hr>
				<br>
				<span class="heading">Recieve Email Notifications</span>

				<span class="options">
				<input type="radio" name="emailOpt" value="yes"> Yes
				<input type="radio" name="emailOpt" value="no" checked> No<br><br>
				<input type="text" name="email" value="<%= profiles.get(0).getEmail() %>"></input> Email Address
				</span>
				<br>
				<hr>
				<br>
				<span class="heading">Recieve Txt Notifications</span>
				<span class="options">
				<input type="radio" name="cellOpt" value="yes"> Yes
				<input type="radio" name="cellOpt" value="no" checked> No<br><br>
				<input type="text" name="cell" value="<%= profiles.get(0).getCellNum() %>" size="11" /> Cell Number
				&nbsp
				<select name="carrier">
					<option value=""><%=profiles.get(0).getCarrier() %></option>
					<option value="att">AT&T</option>
				  	<option value="verizon">Verizon</option>
				  	<option value="tmobile">T-Mobile</option>
				</select> Carrier 
				</span>
				<br>
				<hr>
				<br>
				<input type="hidden" name="id" value="<%= users.get(0).getID()%>" />
				<input type="hidden" name="callback" value="/UserPrefs.jsp" />
				<input type="submit" value="Update"></input>
				</form>
				
				<br><br>
				<form name="testmail" action="/email">
				<input type="hidden" name="to" value="<%= profiles.get(0).getEmail() %>" />
				<input type="hidden" name="cell" value="<%= profiles.get(0).getCellNum() %>" />
				<input type="hidden" name="carrier" value="<%= profiles.get(0).getCarrier() %>" />
				<input type="hidden" name="callback" value="/UserPrefs.jsp";
				<input type="submit" value="SEND TEST EMAIL AND TEXT"></input>
				</form>

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

		</div><!-- contentLeftContext -->
	</div><!-- contentLeft -->
</div><!-- wrappercontent -->
</div><!-- wrapper -->
</body>
</html>
