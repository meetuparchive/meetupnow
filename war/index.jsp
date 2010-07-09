<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="meetupnow.RegDev" %>
<%@ page import="meetupnow.UserInfo" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.compass.core.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<link rel="stylesheet" type="text/css" media="all" href="css/grids.css">
	<link rel="stylesheet" href="/css/ui-lightness/jquery-ui-1.8.2.css" type="text/css" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript" src="/js/index.js"></script>
	<script type="text/javascript">

			<%@ include file="jsp/cookie.jsp" %>
			<%@ include file="jsp/declares.jsp" %>
			<%@ page import="meetupnow.Topic" %>



		
			function loadEvents(){
				
			// Sort Buttons | jQuery UI
			$(function() {
					$("#sortMain").buttonset();
			});
			
			// Select Topic Widget | jQuery UI
			

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

	int numBoxes = 3;

	CompassSearchSession search = PMF.getCompass().openSearchSession();
	RegDev sg = new RegDev();
	String querystring = request.getParameter("query");
	String locationquery = request.getParameter("location");
	if (querystring == null) querystring = "";
	if (locationquery == null) locationquery = "";
	String containers = "&container_id=";
	JSONObject json;
	Boolean searchresults = false;
			String Lat = "";
			String Lon = "";


if (querystring != null && locationquery != null){

	if (!locationquery.equals("")){	

		if (!querystring.equals("")) {

			locationquery = locationquery.replace(' ', '+');
			searchresults = true;
			System.out.println(!querystring.equals("") + " " + !locationquery.equals(""));
			CompassHits hits = null;
			hits = search.queryBuilder().queryString(querystring).toQuery().setTypes(Topic.class).hits();
			String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?address=" + locationquery +"&sensor=true";
			APIresponse = sg.submitUnsignedURL(GEOCODE_API_URL);
			json = new JSONObject(APIresponse.getBody());


			

			Lat =  json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat");
			Lon =  json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");

			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&fields=rsvp_count&radius=10&lat=" + Lat + "&lon=" + Lon;
			if (hits.length() > 0) {

				for (int i = 0; i < hits.length(); i++){
					Topic topic = (Topic) hits.data(i);
					Resource resource = hits.resource(i);
					if (i < hits.length() - 1){			
						containers = containers + Integer.toString(topic.getId()) + ",";

					}else{
						containers = containers + Integer.toString(topic.getId());

					}
				}

				if (hits.getSuggestedQuery().isSuggested()) {
				    System.out.println("Did You Mean: " + hits.getSuggestedQuery());
				}
				API_URL = API_URL + containers;
				System.out.println(API_URL);

			


				APIresponse = sg.submitURL(API_URL);
				json = new JSONObject(APIresponse.getBody());
	%> var data = <%=json.toString() %> ;<%
			} else {
	%> var data = "";<%	
			}

		} else {

		}

	} else {

	}
} else {

}

if (!searchresults){

			API_URL = "http://api.meetup.com/ew/containers?order=name&fields=rsvp_count&offset=0&link=http%3A%2F%2Fjake-meetup-test.appspot.com";
			sg = new RegDev();
			APIresponse = sg.submitURL(API_URL);

			JSONArray top_list;	

		
			String TopicList = "container_id=";
			Query TopicQuery = pm.newQuery(Topic.class);
			TopicQuery.setFilter("id != 0");
			TopicQuery.declareParameters("String reqTokenParam");	//Setup Query

			List<Topic> Topics = new ArrayList<Topic>();
			try {
				Topics = (List<Topic>) pm.detachCopyAll((List<Topic>) TopicQuery.execute(key));
				for (int i = 0; i < Topics.size(); i++){
					TopicList = TopicList + Integer.toString(Topics.get(i).getId()) + ",";
				}
				if (TopicList.charAt(TopicList.length() - 1) == ',')
					TopicList = TopicList.substring(0, TopicList.length() - 1);
			} finally {

			}

			Topic NewTopic;
			
			if (!key.equals("empty")) {

				try {
					users = (List<MeetupUser>) query.execute(key);
					
					if (users.iterator().hasNext()) {
						query = pm.newQuery(UserInfo.class);
						query.setFilter("user_id == u_id");
						query.declareParameters("String u_id");


						List <UserInfo> userInfoList = (List<UserInfo>) query.execute(users.get(0).getID());
						if (userInfoList.iterator().hasNext()){
							Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());

							Lat = userInfoList.get(0).getLat();
							Lon = userInfoList.get(0).getLon();
							distance = userInfoList.get(0).getDistance();
							if (Lat != null && Lon != null){
								if (distance != null){
									API_URL = "http://api.meetup.com/ew/events/?status=upcoming&" + TopicList + "&lat=" + Lat + "&lon=" + Lon + "&radius=" + distance + "&fields=rsvp_count&order=time";
								} else {
									API_URL = "http://api.meetup.com/ew/events/?status=upcoming&" + TopicList + "&lat=" + Lat + "&lon=" + Lon + "&radius=20&fields=rsvp_count&order=time";
								}
							}
							else {
								API_URL = "http://api.meetup.com/ew/events.json?lat=40.7142691&lon=-74.0059729&radius=5&fields=geo_ip";
								APIresponse = sg.submitURL(API_URL);
								json = new JSONObject(APIresponse.getBody());
								Lat = json.getJSONObject("meta").getJSONObject("geo_ip").getString("lat");
								Lon = json.getJSONObject("meta").getJSONObject("geo_ip").getString("lon");
								API_URL = "http://api.meetup.com/ew/events?status=upcoming&" + TopicList + "&lat=" + Lat + "&lon=" + Lon + "&radius=25.0&fields=rsvp_count&order=time";

							}
							APIrequest = new Request(Request.Verb.GET, API_URL);
							scribe.signRequest(APIrequest,accessToken);
							APIresponse = APIrequest.send();
							%>data = <%=APIresponse.getBody().toString()%><%
						}
					}
				}
				finally {

				}
			}
			else {
				API_URL = "http://api.meetup.com/ew/events.json?lat=40.7142691&lon=-74.0059729&radius=5&fields=geo_ip";
				APIresponse = sg.submitURL(API_URL);
				json = new JSONObject(APIresponse.getBody());
				Lat = json.getJSONObject("meta").getJSONObject("geo_ip").getString("lat");
				Lon = json.getJSONObject("meta").getJSONObject("geo_ip").getString("lon");
				API_URL = "http://api.meetup.com/ew/events?status=upcoming&" + TopicList + "&lat=" + Lat + "&lon=" + Lon + "&radius=25.0&fields=rsvp_count&order=time";
				APIresponse = sg.submitURL(API_URL);
				%>var data = <%=APIresponse.getBody().toString()%><%
	
			}
}		
			String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?latlng=" + Lat + "," + Lon +"&sensor=true";
			APIresponse = sg.submitURL(GEOCODE_API_URL);
			%>User_Lat = <%=Lat + ";\n"%>
			User_Lon = <%=Lon + ";\n"%>
			var geocode = <%=APIresponse.getBody().toString()%>
				var location = 'Events near ' + geocode.results[0].address_components[2].long_name;

				$('#searchResultsHeading').append(location);
				use_everywhere(data);
			}

	</script>
	
	<script type="text/javascript">

	var alerts = new Array();

	$(function() {
	var count = 0;

	<%
	List<NewsItem> newsFeed = new ArrayList<NewsItem>();
	Query newsQuery = pm.newQuery(NewsItem.class);
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
	for (int i=0; i<numBoxes; i++) {
	%>
		addBox(<%=i%>);
	<%
	}
				} finally {
					newsQuery.closeAll();
				}
	%>
	var interval = window.setInterval(loop, 7500);
	function loop() {
		var n = count + <%=numBoxes%>;
		var one = count + 1;
		var two = count + 2;
		$("div:."+count+",."+one+",."+two).fadeTo('slow', 0.0, function () {
					addBox(n);
					n++;
		$("div:."+count+",."+one+",."+two).slideUp(function () {


		});
		count++;
		});


	}
	});

	function item(ty,n,m,e,c,ti,l) {
		this.type = ty;
		this.name = n;
		this.message = m;
		this.eventName = e;
		this.container = c;
		this.time = ti;
		this.link = l;
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
			return "<i>"+alert.name+"</i> created a new event<br> "+contain+": <a href=\""+alert.link+"\"><b>"+alert.eventName+"</b></a><i><br> ~ "+alert.time+"</i>";
		}
		if (alert.type == "event_rsvp") {
			if (alert.eventName == "null") {evName = "an event";}
			else {evName = alert.eventName;}
			if (alert.container == "null") {contain = "";}
			else {contain = " in topic "+alert.container;}
			return "<i>"+alert.name+"</i> will be attending<br><a href=\""+alert.link+"\"><b>"+evName+"</b></a><br>"+contain+" <i><br> ~ "+alert.time +"</i>";
		}

	}

	function addBox(i) {
		$('#out').append("<div class=\""+i+"\"><div class=\"tickerContentBox\">"+formatAlert(alerts[i])+"</div></div>");
	}


	</script>
</head>
<body onload="loadEvents()">
<div id="wrap">
	
<%@ include file="jsp/header.jsp" %>

<%//@ include file="jsp/ticker.jsp" %>
<div id="main">
	<div id="contentBottom">
		<div id="contentBottomBody">
			<div id="ticker">
				<div class="tickerContext" id="out">

				</div>
			</div>
			<div id="action">
			
			<% if(k.equals("empty")) { %>
			
			<span class="title">Get Started.</span>
			<div id="actionDesc">
				<span class="heading">MeetupNow is a site built so that you can find events happening locally, and happening soon. Nothing going on near you? No problem, just start something yourself, and people nearby will hear about it. Now go out and do something.</span>
			</div> <!-- end #actionDesc -->
			
			<% } %>
			
			<div id="actionBtns">
			<a href="CreateEvent.jsp" class="btn_main" style="float:right; margin-left: 12px">Create An Event</a>
			<a href="lucky" class="btn_main" style="float:right; margin-left: 12px">Roll the Dice!</a>
			<a href="AllTopics.jsp" class="btn_main" style="float:right; margin-left: 12px">Browse Events</a>
			</div><!-- end #actionBtns -->
			
			<!-- <div class="line">
				<div class="unit size1of3">
					<a href="CreateEvent.jsp" class="btn_main fltlft">Create An Event</a>
				</div>
				<div class="unit size1of3">
					<a href="lucky" class="btn_main" style="margin: 0 auto;">Roll the Dice!</a>
				</div>
				<div class="unit size1of3 lastUnit">
					<a href="AllTopics.jsp" class="btn_main fltrt">Browse Events</a>
				</div> 
			</div> -->
			</div><!-- end #action -->
			
			
			<div class="map_contextLeft">
				<span class="map_title title">Happening NOW near you...</span>
				<div id="map_canvasContainerMain">
					<div id="map_canvas">

				</div><!-- end #map_canvas -->
			</div><!-- end #map_canvasContainer -->
			</div><!-- end .map_context -->
			
			<div class="line">
				<div class="unit size2of3">
					<div class="mainListActions">
					<form action="index.jsp" method="post" accept-charset="utf-8">
						<div class="element">
							<div class="label">
								<label for="location">City or Postal Code</label>
							</div> <!-- end .label -->
							<select class="fltlft" id="topicSelect" name="topic">
								<option value="-1">All Topics</option>
								<option value="936">Sports</option>
								<option value="941">TV/Movies</option>
								<option value="942">Study Groups</option>
								<option value="943">Eating/Getting Meals</option>
								<option value="944">Hiking/Walking/Exersize</option>
								<option value="945">Other</option>
								<option value="946">Community Service</option>
								<option value="947">Gaming(Electronic/Traditional)</option>
								<option value="948">Sightseeing</option>
								<option value="949">Parties</option>
							</select>
						</div><!-- end .element -->
						<div class="element">
							<div class="label">
								<label for="location">City or Zip Code</label>
							</div> <!-- end .label -->
							<div class="mainSearchInput">
								<input type="text" name="location" value="<%=locationquery.replace('+',' ')%>" id="mainSearchLocation" maxlength="100">
							</div> <!-- end .input -->
						</div> <!-- end .element -->
						<div class="submit">
							<input type="submit" value="Search" class="submitBtn">
						</div> <!-- end .submit -->
					</form>
					</div>
				</div>
				<div class="unit size1of3 lastUnit">
				<div id="sortMain">	
				<div class="mainListActions fltrt">
					<div class="label">
						<label for="sortBy">Sort By</label>
					</div>
					<input type="radio" id="sortTime" name="sortBy" checked="checked" onclick="eventArray.sort(SortByTime); update_events(current_page);"><label for="sortTime">Time</label>
					<input type="radio" id="sortDistance" name="sortBy" onclick="eventArray.sort(SortByDistance); update_events(current_page);"><label for="sortDistance">Distance</label>
					<input type="radio" id="sortPop" name="sortBy" onclick="eventArray.sort(SortByRSVP); update_events(current_page);"><label for="sortPop">Popularity</label>
				</div><!-- end #sortMainBtnWrap -->
				</div><!-- end .sortMain -->
				</div>
			</div>
			
					
			
			<div id="mn_geoListContext">
			<div id="mn_geoListHeader">
				<span id="searchResultsHeading" class="listTitle"></span>
			</div><!-- mn_geoListHeader -->
			<div id="mn_geoListBody">

			</div> <!-- end #mn_geoListBody -->
			<div id="mn_geoListFooter">
				<div id="searchResultsNav">
					<span class="showAll"></span>
					<span class="paginationNav"></span>
				</div> <!-- end searchResultsNav -->
			</div><!-- mn_geoListFooter -->
			</div><!-- mn_geoListContext -->
		</div> <!-- end #contentLeftBody -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #main -->
</div> <!-- end #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>
