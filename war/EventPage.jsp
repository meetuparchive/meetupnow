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
<%@ page import="java.util.Date" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>
<%
String ev_id = "";
String lucky = "";
String meta_title = "Meetup Now Event";
String meta_desc = "This meetup is happening soon! Check it out.";
	
if (request.getQueryString() != null) {

	if (request.getQueryString().startsWith("id=")) {
		ev_id = request.getParameter("id");
		lucky = request.getParameter("lucky");
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
	<script type="text/javascript">

	function getTimeString (millis) {

		var m_names = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");

		var d = new Date(millis);

		var curr_date = d.getDate();
		var curr_month = d.getMonth();
		var curr_year = d.getFullYear();
		var a_p = "";
		var curr_hour = d.getHours();

		if (curr_hour < 12){
	   		a_p = "AM";
	   	}
		else {
	   		a_p = "PM";
		}
		if (curr_hour == 0) {
	  		curr_hour = 12;
	   	}
		if (curr_hour > 12){
	   		curr_hour = curr_hour - 12;
	   	}

		var curr_min = d.getMinutes();
		curr_min = curr_min + "";

		if (curr_min.length == 1){
	   		curr_min = "0" + curr_min;
	   	}
		curr_month++;

		return (curr_month + "/" + curr_date + "/" + curr_year+" "+curr_hour + ":" + curr_min + " " + a_p);

	}
	</script>
</head>
<body>

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
Date d = new Date();
DateFormat df = DateFormat.getInstance();
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

<div id="wrap">
	<%@ include file="jsp/header.jsp" %>
		<div id="main">
		<div id="contentTop">
			<div id="contentTopBody">
				<div id="ctMap">
					<img src="http://maps.google.com/maps/api/staticmap?zoom=14&size=150x150&maptype=roadmap&markers=color:blue|size:large|<%=item.getString("lat")+","+item.getString("lon")%>&sensor=false"/>
				</div> <!-- end ctMap -->
				<div id="ctInfo">
					
				</div> <!-- end ctInfo -->
			</div> <!-- end contentTopBody -->
		</div>
		<div id="contentRight">
		<div id="contentRightBody">
			<div class="map_context">
				<div id="map_canvasContainer">
					<div id="map_canvas">
						<img src="http://maps.google.com/maps/api/staticmap?zoom=14&size=360x203&maptype=roadmap&markers=color:blue|size:large|<%=item.getString("lat")+","+item.getString("lon")%>&sensor=false"/>
					</div><!-- end #map_canvas -->
				</div><!-- end #map_canvasContainer -->
			</div><!-- end .map_context -->
			<div id="eventInfo">
	<%
			String evname = "Event #"+ev_id;
			try {
				evname = item.getString("title");
			} catch (Exception e){
		
			}
	%>
				<span class="title eventInfo_title"><%=evname%></span>
				<span class="subtitle eventInfo_group"><a href="/Topic?<%=item.getJSONObject("container").getString("id") %>"><%=item.getJSONObject("container").getString("name") %></a></span>
				<div class="eventInfo_block">
					<span class="eventInfo_label">WHEN:</span>
						<span class="eventInfo_text">
							<script type="text/javascript">document.write(getTimeString(<%=Long.parseLong(item.getString("time"))%>));</script>
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
					<a href="/EventRegister?id=<%=ev_id%>&action=remove&r_id=<%=rsvpID%>&callback=/Event?<%=ev_id%>" class="inBtn">I'm In</a>
	<%
		} else {
			if (!key.equals("empty")) {
	%>
					<a href="/EventRegister?id=<%=ev_id%>&action=join&callback=/Event?<%=ev_id%>" class="rsvpBtn">RSVP</a>
	<%
			} else {
	%>
					<a href="#modal_login" name="modal" class="rsvpBtn">RSVP</a>
	<%
			}
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
		</div> <!-- end #contentRightBody -->
		</div> <!-- end #contentRight -->
		<div id="contentLeft">
			<div id="contentLeftBody">
				<div class="custom" style="width:540px; height:203px; background-color:#666"></div>
				<div id="commentFeedContext">
					<div id="activityFeed">
<%
						try {
							if (lucky.equals("true")) {
%>
			<a href="/lucky">Give me another lucky event!</a><br><br>
<%
							}
						} catch (Exception e) {}

%>
						<span class="title">Event Buzz.</span>

							<div class="commentHeadBlock">
<%
							if (key.equals("empty")) {
%>
								<a href="#modal_login" name="modal">Add a Comment</a>
<%
							} else {
%>
								<a href="#commentInputContext" name="commentToggle">Add a Comment</a>
<%
							}
%>
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
	%>
<div class="commentFeedItem">
	<span class="comment_body">
		<span class="comment_author">
			<%=comment.getJSONObject("member").getString("name") %>
		</span>
		<span class="comment_text">
			<%=comment.getString("comment")%>
		</span>
	</span>
	<span class="comment_time">
			<script type="text/javascript">document.write(getTimeString(<%=Long.parseLong(comment.getString("time"))%>));</script>
	</span>
</div>


	<%
		}
	} catch (Exception j) {

	}
	%>
						</div>
					</div>
				</div> <!-- end #activityFeed -->
		


			</div> <!-- end #contentLeftBody -->
		</div> <!-- end #contentLeft -->
	</div> <!-- end #main -->
</div> <!-- end #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>


