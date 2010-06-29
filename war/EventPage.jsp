<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="meetupnow.RegDev" %>
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

	}else {ev_id = request.getQueryString();}
}
%>

	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<meta name="title" content="Meetup Now Event" />
	<meta name="description" content="This meetup is happening soon! Check it out." />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script src="js/eventPage.js"></script>
</head>
<body id="meetupNowBody">


<%@ include file="jsp/header.jsp" %>

<%

String MUID = "";
if (!key.equals("empty")) {	
	try {
		users = (List<MeetupUser>) query.execute(key);
		if (users.iterator().hasNext()) {
			MUID = users.get(0).getID();
		}
	} catch (Exception e) {}
}
RegDev sg = new RegDev();
APIresponse = sg.submitURL("http://api.meetup.com/ew/events/?event_id="+ev_id+"&fields=rsvp_count");
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
			<span class="subtitle eventInfo_group"><a href="/Group?<%=item.getJSONObject("container").getString("id") %>"><%=item.getJSONObject("container").getString("name") %></a></span>
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
					<%
								try{
					%>
					<%=item.getString("address1") %><br>
					<%
								}catch (Exception e) {}
					%>
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

<%
Response rsvpResponse = sg.submitURL("http://api.meetup.com/ew/rsvps?event_id="+ev_id);
JSONObject rsvpjson = new JSONObject();
JSONArray members;
try {
	rsvpjson = new JSONObject(rsvpResponse.getBody());
	members = rsvpjson.getJSONArray("results");
	String userList = "";
	boolean in = false;
	String rsvpID = "";
	for (int j = 0; j < members.length(); j++) {
		
		String tempName = members.getJSONObject(j).getJSONObject("member").getString("name");
		userList = userList.concat("<li>"+tempName+"</li>");	
		if (!MUID.equals("")) {
			if (MUID.equals(members.getJSONObject(j).getJSONObject("member").getString("member_id"))) {
				in = true;
				rsvpID = members.getJSONObject(j).getString("id");
			}
		}
	}


%>

			<div class="eventInfo_block">
<%
	if (in) {
%>
				You're in! <a href="/EventRegister?id=<%=ev_id%>&action=remove&r_id=<%=rsvpID%>&callback=/Event?<%=ev_id%>">(Click to remove)</a>
<%
	} else {
%>
				<a href="/EventRegister?id=<%=ev_id%>&action=join&callback=/Event?<%=ev_id%>">RSVP</a>
<%
	}
%>
				<br><br>
				<span class="title"><%=item.getString("rsvp_count") %> RSVP(s).</span>
				<ul id="attendeesList">
					<%=userList%>
<%

}
catch (JSONException j) {

}
%>
				</ul>
			</div>
		</div> <!-- end #eventInfo -->
	</div> <!-- end #contentRight -->
	<div id="contentLeft">
		<div id="contentLeftContext">
			<div class="custom" style="width:540px; height:203px; background-color:#666"></div>
			
			<div id="commentFeedContext">
				<div id="activityFeed">
					<span class="title">Event Buzz.</span>

						<div class="commentHeadBlock">
							<a href="#commentInputContext" name="commentToggle">Add a Comment</a>
						</div>
						<div id="commentInputContext">
							<form action="/comment" method="get">
								<textarea name="comment" class="input textarea"></textarea>
								<input type="hidden" name="id" value="<%=ev_id%>" />
								<input type="hidden" name="callback" value="Event?<%=ev_id%>" />
								<input type="hidden" name="title" value="<%=title%>" />
								<input type="submit" value="Post" class="submitCommentBtn"/>
							</form>
						</div> <!-- end #commentInputContext -->

					<div id="activity">
						<%
	}else {

	}

} catch (Exception j) {

}

Response CommentResponse = sg.submitURL("http://api.meetup.com/ew/comments/?event_id="+ev_id);
JSONObject j2 = new JSONObject();
JSONArray cResults;
try {
	j2 = new JSONObject(CommentResponse.getBody());
	cResults = j2.getJSONArray("results");
	for (int i = 0; i < cResults.length(); i++) {
		JSONObject comment = cResults.getJSONObject(i);
		cal.setTimeInMillis(Long.parseLong(comment.getString("time")));
						%>
						<div class="commentFeedItem"><span class="comment_body"><span class="comment_author"><%=comment.getJSONObject("member").getString("name") %></span><span class="comment_text"><%=comment.getString("comment")%></span></span><span class="comment_time"><%=df.format(cal.getTime()) %></span></div>


						<%
	}
} catch (Exception j) {

}
						%>
					</div>
				</div>
			</div> <!-- end #activityFeed -->
			


		</div> <!-- end #contentLeftContext -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->
</div> <!-- end #wrapper -->

<%@ include file="jsp/footer.jsp" %>

