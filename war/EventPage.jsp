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
<%@ page import="java.util.TimeZone" %>
<%@ page import="java.text.DateFormat" %>


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
		String ev_id = "";
		
		if (request.getQueryString() != null) {
			ev_id = request.getQueryString();
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
										<div id="mn_geoListHeader">

										</div><!-- mn_geoListHeader -->
<%
if (users.iterator().hasNext()) {
	Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
	APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/events/?event_id="+ev_id);
	scribe.signRequest(APIrequest,accessToken);
	APIresponse = APIrequest.send();
	JSONObject json = new JSONObject();
	JSONArray results;
	Calendar cal = Calendar.getInstance();
	DateFormat df = DateFormat.getInstance();
	df.setTimeZone(TimeZone.getTimeZone("GMT-4"));
	try {
		json = new JSONObject(APIresponse.getBody());
		results = json.getJSONArray("results");
		if (results.length() == 1) {
			JSONObject item = results.getJSONObject(0);
			cal.setTimeInMillis(Long.parseLong(item.getString("time")));


%>
<%=item.getJSONObject("container").getString("name") %> Event #<%=ev_id%>
<br>
<%=df.format(cal.getTime()) %>
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
<br>
<br>
What people are saying: <br>
<%

		}
		else {

		}

	} catch (Exception j) {
			
	}
	Request CommentRequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/comments/?event_id="+ev_id);
	scribe.signRequest(CommentRequest,accessToken);
	Response CommentResponse = CommentRequest.send();
	JSONObject j2 = new JSONObject();
	JSONArray cResults;
	try {
		j2 = new JSONObject(CommentResponse.getBody());
		cResults = j2.getJSONArray("results");
		for (int i = 0; i < cResults.length(); i++) {
			JSONObject comment = cResults.getJSONObject(i);
			cal.setTimeInMillis(Long.parseLong(comment.getString("time")));
%>
<%=comment.getJSONObject("member").getString("name") %> @ <%=df.format(cal.getTime()) %> <br> &nbsp &nbsp - &nbsp <%=comment.getString("comment")%> <br>


<%		

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
