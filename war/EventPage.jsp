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
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>
<%
	String ev_id = "";
	String meta_title = "Meetup Now Event";
	String meta_desc = "This meetup is happening soon! Check it out.";
	
	if (request.getQueryString() != null) {

		if (request.getQueryString().startsWith("id=")) {
			ev_id = request.getParameter("id");
			//META INFO

		}
		else {ev_id = request.getQueryString();}
	}
%>

	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<meta name="title" content="Meetup Now Event" />
	<meta name="description" content="This meetup is happening soon! Check it out." />
</head>
<body id="meetupNowBody">


<%@ include file="jsp/header.jsp" %>

<%

	if (!key.equals("empty")) {
		try {
			users = (List<MeetupUser>) query.execute(key);
%>

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
			String desc = "";
			try {
				desc = item.getString("description");
			} catch (Exception e) {}
%>

<div id="wrapper">
<div id="wrapperContent">
	<div id="contentRight">
		<div class="map_context">
			<div id="map_canvasContainer">
				<div id="map_canvas">
					<img src="http://maps.google.com/maps/api/staticmap?zoom=14&size=360x203&maptype=roadmap&markers=color:blue|size:large|<%=item.getString("lat")+","+item.getString("lon")%>&sensor=false"/>
				</div><!-- end #map_canvas -->
			</div><!-- end #map_canvasContainer -->
		</div><!-- end .map_context -->
		<div id="eventInfo">
			<span class="title eventInfo_title">Event #<%=ev_id%></span>
			<span class="subtitle eventInfo_group"><%=item.getJSONObject("container").getString("name") %></span>
			<div class="eventInfo_block">
				<span class="eventInfo_label">WHEN:</span>
				<span class="eventInfo_text">
					<%=df.format(cal.getTime()) %>
				</span> <!-- end eventInfo_text -->
			</div> <!-- end .eventInfo_block -->
			<div class="eventInfo_block">
				<span class="eventInfo_label">WHERE:</span>
				<span class="eventInfo_text">
					<%=item.getString("venue_name") %><br>
					<%=item.getString("city") %>, 
					<%
								try{
					%>
					<%=item.getString("state") %>
					<%		
								} catch (JSONException j) {
					%>			
					<%=item.getString("country").toUpperCase() %><br>
					<%
								}
					%>
				</span> <!-- end eventInfo_text -->
			</div> <!-- end .eventInfo_block -->
			<div class="eventInfo_block">
				<span class="eventInfo_desc">
					<%=desc %>
				</span> <!-- end .eventInfo_desc -->
			</div> <!-- end .eventInfo_block -->
			<div class="eventInfo_block">
				<%
					String title = ev_id;
					try {
					title = item.getString("title");
				%>

				<%
					} catch (Exception e) {

					}
				%>
			</div> <!-- end .eventInfo_block -->
		</div> <!-- end #eventInfo -->
	</div> <!-- end #contentRight -->
	<div id="contentLeft">
		<div id="contentLeftContext">

Add a comment
<form action="/comment" method="get">
<textarea name="comment" cols="40" rows="3"></textarea>
<input type="hidden" name="id" value="<%=ev_id%>" />
<input type="hidden" name="callback" value="Event?<%=ev_id%>" />
<input type="hidden" name="title" value="<%=title%>" />
<input type="submit" value="Submit" />
</form>
What people are saying: <br><br>
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
<i><%=comment.getJSONObject("member").getString("name") %> @ <%=df.format(cal.getTime()) %></i> <br> &nbsp &nbsp - &nbsp <%=comment.getString("comment")%> <br>


<%
		}
	} catch (Exception j) {

	}
}
%>

		</div> <!-- end #contentLeftContext -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->
</div> <!-- end #wrapper -->

<%@ include file="jsp/footer.jsp" %>
<%
			} finally {
				query.closeAll();
			}
		}
%>
