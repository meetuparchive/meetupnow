<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="meetupnow.RegDev" %>
<%@ page import="meetupnow.UserInfo" %>
<%@ page import="meetupnow.Topic" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>

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



		    var data;

            function setData(d) {
                if (d.results.length > 0) {
                    data = d;
                } else {
                    data = null;
                }
            }


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


	RegDev sg = new RegDev();
	String querystring = request.getParameter("topic");
	String locationquery = request.getParameter("location");
	if (querystring == null) querystring = "";
	if (locationquery == null) locationquery = "";
    String topicList = "&container_id=";

	Query topicQuery = pm.newQuery(Topic.class);
	topicQuery.setFilter("id != 0");
	topicQuery.declareParameters("String reqTokenParam");	//Setup Query

	List<Topic> Topics = new ArrayList<Topic>();
	try {
		Topics = (List<Topic>) pm.detachCopyAll((List<Topic>) topicQuery.execute(key));
		for (int i = 0; i < Topics.size(); i++){
			topicList = topicList + Integer.toString(Topics.get(i).getId()) + ",";
		}
    	if (topicList.charAt(topicList.length() - 1) == ',')
		    topicList = topicList.substring(0, topicList.length() - 1);
	} finally {
        topicQuery.closeAll();
	}
    String allTopicList = topicList;
	if (!querystring.equals("0") && !querystring.equals("")){
		topicList = "&container_id=" + querystring;
	}
	JSONObject json;
	Boolean searchresults = false;
			String Lat = "";
			String Lon = "";


if (querystring != null && locationquery != null){

	if (!querystring.equals("")) {
		
		//display search results
		searchresults = true;
		if (!locationquery.equals("")){	


			locationquery = locationquery.replace(' ', '+');

			//String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?address=" + locationquery +"&sensor=true";
            String gisgraphy_url = "http://services.gisgraphy.com/fulltext/fulltextsearch?q="+ locationquery +"&placetype=city&country=us&format=json&from=1&to=1";
			APIresponse = sg.submitUnsignedURL(gisgraphy_url);
			json = new JSONObject(APIresponse.getBody());
            JSONObject g_response = json.getJSONObject("response");
            if (Integer.parseInt(g_response.getString("numFound")) > 0) {
			    Lat =  g_response.getJSONArray("docs").getJSONObject(0).getString("lat");
			    Lon =  g_response.getJSONArray("docs").getJSONObject(0).getString("lng");

			    API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&status=upcoming&fields=rsvp_count&radius=10&lat=" + Lat + "&lon=" + Lon + topicList;
			    APIresponse = sg.submitURL(API_URL);
			    json = new JSONObject(APIresponse.getBody());
	            %> setData(<%=json.toString()%>); <%
            }
            else {
                Lat = null;
                Lon = null;
                %> setData(null);<%
            }




		} else {
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
							if ((Lat != null) && (Lon != null)){
								if (distance != null){
			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&fields=rsvp_count&status=upcoming&radius=" + distance + "&lat=" + Lat + "&lon=" + Lon + topicList;
								} else {
			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&fields=rsvp_count&status=upcoming&radius=10&lat=" + Lat + "&lon=" + Lon + topicList;
								}
							}
							else {
								API_URL = "http://api.meetup.com/ew/events.json?lat=40.7142691&lon=-74.0059729&&status=upcoming&radius=5&fields=geo_ip";
								APIresponse = sg.submitURL(API_URL);
								json = new JSONObject(APIresponse.getBody());
								Lat = json.getJSONObject("meta").getJSONObject("geo_ip").getString("lat");
								Lon = json.getJSONObject("meta").getJSONObject("geo_ip").getString("lon");
			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&fields=rsvp_count&radius=10&status=upcoming&lat=" + Lat + "&lon=" + Lon + topicList;
							}

							APIrequest = new Request(Request.Verb.GET, API_URL);
							scribe.signRequest(APIrequest,accessToken);
							APIresponse = APIrequest.send();
							%>setData(<%=APIresponse.getBody().toString()%>);<%
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
				API_URL = "http://api.meetup.com/ew/events?status=upcoming"+ topicList + "&lat=" + Lat + "&lon=" + Lon + "&radius=25.0&fields=rsvp_count&order=time";
				APIresponse = sg.submitURL(API_URL);
				%>setData(<%=APIresponse.getBody().toString()%>);<%
	
			}


		}

	} else {

	}
} else {

}
%>var search = <%=searchresults + ";\n"%>
<%
if (!searchresults){


			

			JSONArray top_list;	

			
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
							if ((Lat != null) && (Lon != null)){
								if (distance != null){
			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&fields=rsvp_count&status=upcoming&radius=" + distance + "&lat=" + Lat + "&lon=" + Lon + topicList;
								} else {
			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&fields=rsvp_count&status=upcoming&radius=10&lat=" + Lat + "&lon=" + Lon + topicList;
								}
							    APIrequest = new Request(Request.Verb.GET, API_URL);
							    scribe.signRequest(APIrequest,accessToken);
							    APIresponse = APIrequest.send();
							    %>setData(<%=APIresponse.getBody().toString()%>);<%
							}
							else {
	                            Lat = null;
                                Lon = null;
				                %>setData(null);<%

							}


						}
					}
				}
				finally {

				}
			}
			else {

                Lat = null;
                Lon = null;
				%>setData(null);<%

	
			}
}		
			//String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?latlng=" + Lat + "," + Lon +"&sensor=true";
			//APIresponse = sg.submitURL(GEOCODE_API_URL);
%>
            Topic_List = "<%=topicList %>";
            User_Lat = <%=Lat + ";\n"%>
			User_Lon = <%=Lon + ";\n"%>
            if (data == null){
                if (search) {
                    Topic_List = "<%=allTopicList%>";
                }
                $.ajax({
                    dataType: "jsonp", 
                    url: 'http://api.meetup.com/members?relation=self&order=name&offset=0&format=json&page=200&fields=geo_ip&sig_id=12219649&sig=c36e74db72bca240652d609ae875821df5ea9418',
                    success: function(data) {
                        User_Lat = data.meta.geo_ip.lat;
                        User_Lon = data.meta.geo_ip.lon;
                        $.ajax({
                            dataType: "jsonp", 
                            url: "http://api.meetup.com/ew/events?status=upcoming&lat=" + data.meta.geo_ip.lat + "&lon=" + data.meta.geo_ip.lon + "&" + Topic_List + "&radius=25.0&fields=rsvp_count&key=<%=sg.getKey()%>",
                            success: function(data2) {

			                    use_everywhere(data2);
                                eventArray.sort(SortByDistance);
                                var location = '';
                                if (search){
                                    location = 'Results or location not found... Showing all ';
                                }
    				            location = location + 'Events near ' + eventArray[0].ev.city;
                                if (eventArray[0].ev.state){
                                    location = location + ", " + eventArray[0].ev.state;
                                }
                                else{
                                    location = location + ", " + eventArray[0].ev.country.toUpperCase();
                                }

				                $('#searchResultsHeading').append(location);    
                                eventArray.sort(SortByTime);                      
                            }   
                        });
                    }   
                });


            
            } else {
                use_everywhere(data);
                eventArray.sort(SortByDistance);
                var location = 'Events near ' + eventArray[0].ev.city;
                if (eventArray[0].ev.state){
                    location = location + ", " + eventArray[0].ev.state;
                }
                else{
                   location = location + ", " + eventArray[0].ev.country.toUpperCase();
                }

                $('#searchResultsHeading').append(location);    
                eventArray.sort(SortByTime);          


			}
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
			else {evName = "on " + alert.eventName;}
			return "<span class='tickerMember'>"+alert.name+"</span> commented <a href=\""+alert.link+"\">"+evName+"</a>: "+ alert.message+" <span class='tickerTime'> ~ "+alert.time+"</span>";
		}
		if (alert.type == "event_create") {
			if (alert.container == "null") {contain = "";}
			else { contain = "in topic "+alert.container;}
			return "<span class='tickerMember'>"+alert.name+"</span> created a new event "+contain+": <a href=\""+alert.link+"\">"+alert.eventName+"</a><span class='tickerTime'> ~ "+alert.time+"</span>";
		}
		if (alert.type == "event_rsvp") {
			if (alert.eventName == "null") {evName = "an event";}
			else {evName = alert.eventName;}
			if (alert.container == "null") {contain = "";}
			else {contain = " in topic "+alert.container;}
			return "<span class='tickerMember'>"+alert.name+"</span> will be attending <a href=\""+alert.link+"\">"+evName+"</a>"+contain+" <span class='tickerTime'> ~ "+alert.time +"</span>";
		}

	}

	function addBox(i) {
		var index = i;
		if ( i >= alerts.length) {
			index = index % alerts.length;
		}
		$('#out').append("<div class=\""+i+"\"><div class=\"tickerContentBox\">"+formatAlert(alerts[index])+"</div></div>");
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
					<%
					if (!k.equals("empty")) {
					%>
			<a href="CreateEvent.jsp" class="actionBtn" style="float:right; margin-left: 12px">Create An Event</a>
					<%
					} else {
					%>
			<a href="#modal_login" name="modal" class="actionBtn" style="float:right; margin-left: 12px">Create An Event</a>
					<%
					}
					%>
			<a href="lucky" class="actionBtn" style="float:right; margin-left: 12px">Can't Decide?</a>
			<a href="AllTopics.jsp" class="actionBtn" style="float:right; margin-left: 12px">Browse Events</a>
			</div><!-- end #actionBtns -->
			
			<!-- <div class="line">
				<div class="unit size1of3">


					

					
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
								<label for="location">Topic</label>
							</div> <!-- end .label -->
							<select class="fltlft" id="topicSelect" name="topic">
								<option value="0">All Topics</option>
				<%
					Query TopicQuery = pm.newQuery(Topic.class);
					TopicQuery.setFilter("id != 0");
					TopicQuery.declareParameters("String reqTokenParam");	//Setup Query

					List<Topic> topics = new ArrayList<Topic>();
					try {
						topics = (List<Topic>) pm.detachCopyAll((List<Topic>) TopicQuery.execute(key));
					} finally {

					}
						String tString;
						for (int i = 0; i < topics.size(); i++) {
							tString = ""+topics.get(i).getId();
							if (tString.equals(querystring)) {
				%>
							<option value="<%=topics.get(i).getId()%>" selected><%=topics.get(i).getName()%></option>
				<%
							} else {
				%>
							<option value="<%=topics.get(i).getId()%>"><%=topics.get(i).getName()%></option>
				<%
							}
						}
				%>
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
							<input type="submit" value="Search" class="actionBtn submitBtn">
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
