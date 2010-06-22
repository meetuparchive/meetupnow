<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>

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
				
%>
	
alerts[<%=i%>] = new item("<%=n.getType()%>","<%=n.getName()%>","<%=n.getMessage()%>","<%=n.getEvConName()%>","<%=n.getContainerName()%>","<%=n.getTimeCreated()%>");

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
	for (i = frameNum - 1; i >= 0 ; i=i-1) {
		out.append(contain(alerts[(alerts.length - 1 - counter - i)%alerts.length]));
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
	return "<div class=\"activityFeedItem\">"+alert.name+": "+alert.message+"<span></span></div>";
}

function item(ty,n,m,e,c,ti) {
	this.type = ty;
	this.name = n;
	this.message = m;
	this.eventName = e;
	this.container = c;
	this.time = ti;
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
			<div id="mn_geoListFooter">
		
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
<div id="mew_footer">
	<div id="mew_footerBody">
		<div id="mew_footerLogo">
			<img src="images/logo_footer.png" alt="MeetupNow" style="width: auto !important; height: auto !important">
		</div> <!-- end mew_footerLogo -->
		<div id="mew_footerRow">
			<ul class="mew_footerSection">
				<li>About Meetup Now</li>
				<li>Contact Us</li>
				<li>Placeholder</li>
			</ul>
		</div><!-- mew_footerRow -->
		
	</div><!-- mew_footerBody -->
</div><!-- mew_footer -->
</body>
</html>
