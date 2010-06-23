<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>

<!DOCTYPE html>
<html>
<head>
	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/redesign.css" type="text/css" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript" src="/js/index.js"></script>
	<script type="text/javascript">
	  function initialize() {
	    var myLatlng = new google.maps.LatLng(-34.397, 150.644);
	    var myOptions = {
	      zoom: 8,
	      center: myLatlng,
	      mapTypeId: google.maps.MapTypeId.ROADMAP
	    }
	    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	  }
	</script>
<script type="text/javascript">



$(function() {

var out = $('#activity');

var alerts = new Array();
var counter = 0;
var frameNum = 3;
var frames = new Array();

<%!
public static String timeBetween(Date d1, Date d2){
	long now = d1.getTime();
	long then = d2.getTime();
	
	long seconds = (now - then)/1000;
	long minutes = seconds/60;
	long hours = minutes/60;
	long days = hours/24;

	if (seconds < 60) {
		if (seconds == 1) {return seconds+" second ago";}
		else {return seconds+" seconds ago";}
	}
	if (minutes < 60) {
		if (minutes == 1) {return minutes+" minute ago";}
		else {return minutes+" minutes ago";}
	}
	if (hours < 24) {
		if (hours == 1) {return hours+" hour ago";}
		else {return hours+" hours ago";}
	}
	if (days == 1) {return days+" day ago";}
	else {return days+" days ago";}

}
%>

<%
PersistenceManager pmr = PMF.get().getPersistenceManager();
List<NewsItem> newsFeed = new ArrayList<NewsItem>();
Query newsQuery = pmr.newQuery(NewsItem.class);
newsQuery.declareParameters("long startdate");
newsQuery.setFilter("timeCreated > startdate");
newsQuery.setOrdering("timeCreated descending");

			try {
				newsFeed = (List<NewsItem>) newsQuery.execute(0);
				for (int i = 0; i < newsFeed.size(); i++) {
					NewsItem n = newsFeed.get(i);
					Date now = new Date();
					Date then = new Date(n.getTimeCreated());
				
%>
	
alerts[<%=i%>] = new item("<%=n.getType()%>","<%=n.getName()%>","<%=n.getMessage()%>","<%=n.getEvConName()%>","<%=n.getContainerName()%>","<%=timeBetween(now,then)%>","<%=n.getLink()%>");

<%
				}
			} finally {
				newsQuery.closeAll();
			}
%>
var i;
for (i = 0; i < frameNum; i=i+1) {
	frames[i] = contain(alerts[i]);
}

var interval = window.setInterval(loop, 0);

function loop() {
	var i;
	out.empty();
	var index;
	for (i = frameNum - 1; i >= 0 ; i=i-1) {
		index = alerts.length - 1 - counter - i;
		if (index < 0) {index = index + alerts.length}
		out.append(contain(alerts[index]));
	}
	counter = counter + 1;
	if (counter >= alerts.length) {
		counter = 0;
	}

	var randomnumber = Math.floor(Math.random()*15000)
	if (randomnumber < 5000) {randomnumber = 5000};
	window.clearInterval(interval);
	interval = window.setInterval(loop, randomnumber);
}

});

function contain(alert) {
	return "<div class=\"activityFeedItem\"><span>"+ formatAlert(alert) +"</span></div>";
}

function formatAlert(alert) {
		var evName;
		var contain;
	if (alert.type == "comment") {
		if (alert.eventName == "null") { evName = "on an event"; }
		else {evName = "on event " + alert.eventName;}
		return "<i>"+alert.name+"</i> commented <a href=\""+alert.link+"\"><b>"+evName+"</b></a>: <b>"+ alert.message+"</b> <i> ~ "+alert.time+"</i>";
	}
	if (alert.type == "event_create") {
		if (alert.container == "null") {contain = "";}
		else { contain = "in topic "+alert.container;}
		return "<i>"+alert.name+"</i> created a new event "+contain+": <a href=\""+alert.link+"\"><b>"+alert.eventName+"</b></a>: "+alert.message+" <i> ~ "+alert.time+"</i>";
	}
	if (alert.type == "event_rsvp") {
		if (alert.eventName == "null") {evName = "an event";}
		else {evName = alert.eventName;}
		if (alert.container == "null") {contain = "";}
		else {contain = " in topic "+alert.container;}
		return "<i>"+alert.name+"</i> is hitting up <a href=\""+alert.link+"\"><b>"+evName+"</b></a>"+contain+" <i> ~ "+alert.time +"</i>";
	}
	
}


function item(ty,n,m,e,c,ti,l) {
	this.type = ty;
	this.name = n;
	this.message = m;
	this.eventName = e;
	this.container = c;
	this.time = ti;
	this.link = l;
}

</script>



<script type="text/javascript">

		
		function loadEvents(){
		<%@ include file="jsp/cookie.jsp" %>

		<%

		

		if (!key.equals("empty")) {
			try {
				users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					API_URL = "http://api.meetup.com/ew/events/?status=upcoming&urlname=muntest&lat=" + users.get(0).getLat() + "&lon=" + users.get(0).getLon() + "&radius=" + distance;
					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					%>var data = <%=APIresponse.getBody().toString()%><%
				}
			}
			finally {

			}
		}
		else {

			API_URL = "http://api.meetup.com/ew/events?status=upcoming&radius=25.0&order=time&offset=0&format=json&page=200&container_id=654&sig_id=12219924&sig=73487b47859ee335994dac5770ba0d18";
			APIrequest = new Request(Request.Verb.GET, API_URL);
			APIresponse = APIrequest.send();
			%>var data = <%=APIresponse.getBody().toString()%><%
	
		}
		%>
			use_everywhere(data);
		}

	</script>
</head>
<body onload="loadEvents()">

<%@ include file="jsp/header.jsp" %>
<div id="wrapper">
<div id="wrapperContent">
	<div id="contentRight">
		<div class="map_context">
			<span class="map_title title">Happening NOW near you...</span>
			<div id="map_canvasContainer">
				<div id="map_canvas">
		
				</div><!-- end #map_canvas -->
			</div><!-- end #map_canvasContainer -->
		</div><!-- end .map_context -->
		<div id="searchContext">
			<div id="search">
				<form action="search" method="post" accept-charset="utf-8">
					<div class="element">
						<div class="label">
							<label for="query">Search for: </label>
						</div> <!-- end .label -->
						<div class="input">
							<input type="text" name="query" value="" id="query" size="20" maxlength="100">
						</div> <!-- end .input -->
					</div> <!-- end .element -->
					<div class="element">
						<div class="label">
							<label for="location">City or Postal Code</label>
						</div> <!-- end .label -->
						<div class="input">
							<input type="text" name="location" value="" id="location" size="15" maxlength="100">
						</div> <!-- end .input -->
					</div> <!-- end .element -->

						<div class="submit">
							<input type="submit" value="Search" class="submitBtn">
						</div> <!-- end .submit -->
				</form>
			</div> <!-- end #search -->
		</div> <!-- end #searchContext -->
		<div id="mn_geoListContext">
			<div id="mn_geoListHeader">
				<span class="listTitle">Results near [location]</span>
			</div><!-- mn_geoListHeader -->
			<div id="mn_geoListBody">
				<a href="#" class="mn_geoListItem_link">
					<span class="mn_geoListItem">
						<span class="when">
							<span class="mn_geoListItem_date">6/16</span>
							<span class="mn_geoListItem_time">1:00 pm</span>
						</span> <!-- end .when -->
						<span class="details">
							<span class="mn_geoListItem_title">Flag Football</span>
							<span class="loc">
								<span class="mn_geoListItem_address">555 1st Ave.</span>
								<span class="mn_geoListItem_city">New York, NY</span>
							</span> <!-- end .loc -->
						</span> <!-- end .details -->
					</span> <!-- end .mn_geoListItem -->
				</a>
				<a href="#" class="mn_geoListItem_link">
					<span class="mn_geoListItem">
						<span class="when">
							<span class="mn_geoListItem_date">6/17</span>
							<span class="mn_geoListItem_time">5:30 pm</span>
						</span> <!-- end .when -->
						<span class="mn_geoListItem_title">Rugby</span>
						<span class="loc">
							<span class="mn_geoListItem_address">555 1st Ave.</span>
							<span class="mn_geoListItem_city">Brooklyn, NY</span>
						</span> <!-- end .loc -->
					</span> <!-- end .mn_geoListItem -->
				</a>
			</div> <!-- end #mn_geoListBody -->
			<div id="mn_geoListFooter">
				<div id="searchResultsNav">
					<span class="showAll"></span>
					<span class="paginationNav"></span>
				</div> <!-- end searchResultsNav -->
			</div><!-- mn_geoListFooter -->
		</div><!-- mn_geoListContext -->
	</div> <!-- end #contentRight -->
	<div id="contentLeft">
		<div id="actionContext">
			<span class="title">Get Started.</span>
			<div id="action">
				<a href="#"><span class="btn_main">Register</span></a>
				<a href="#"><span class="btn_main">Create Event</span></a>
				<a href="#"><span class="btn_main">Search</span></a>
			</div> <!-- end #action -->
			<div id="actionDesc">
				<span class="heading">MeetupNow is a platform built to Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. </span>
				<span class="heading">Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</span>
			</div> <!-- end #actionDesc -->
		</div> <!-- end #actionContext -->
		<div id="activityFeedContext">
			<div id="activityFeed">
				<span class="title">Activity Feed.</span>
				<div id = "activity"> </div>
			</div>
		</div> <!-- end #activityFeed -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->

</div> <!-- end #wrapper -->
<div id="footer">
	<div id="footerBody">
		<div id="footerLogo">
			<img src="images/logo_footer.png" alt="MeetupNow" style="width: auto !important; height: auto !important">
		</div> <!-- end footerLogo -->
		<div id="footerRow">
			<ul class="footerSection">
				<li>About Meetup Now</li>
				<li>Contact Us</li>
				<li>Placeholder</li>
			</ul>
		</div><!-- footerRow -->
		
	</div><!-- footerBody -->
</div><!-- footer -->
</body>
</html>
