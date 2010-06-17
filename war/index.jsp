<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>

<%@ page import="java.io.IOException" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="meetupnow.OAuthServlet" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript">

	var map;


	var eventArray = new Array();	
	var eventDescription = $('#mn_eventDescription');	
	eventDescription.empty();

	function changeDiscription(desc){
		var eventDescription = $('#mn_eventDescription');
		eventDescription.empty();
		alert(desc);
		eventDescription.append(desc);	
	}

	function topic_show(event_id){
		changeDiscription("");
		for (var i = 0; i < eventArray.length; i++){
			if (event_id == -1) {
				eventArray[i].marker.setVisible(true);
			}
			else{
				if (eventArray[i].id == event_id){
					eventArray[i].marker.setVisible(true);
					changeDiscription(eventArray[i].description + '<br><br><a href="/Event?' + eventArray[i].id + '" Group Page </a>');

					
				} else {
					eventArray[i].marker.setVisible(false);
				}
			}
			
		}

	}

	function create_map(){
		map = new google.maps.Map(document.getElementById("map_canvas"), {
      			zoom: 15,
      			center: new google.maps.LatLng(0,0),
      			mapTypeId: google.maps.MapTypeId.ROADMAP
    		});
	}

	function use_everywhere(){
			var event_object;
			var bounds = new google.maps.LatLngBounds();

			var events = $('#mn_geoListContext');

			//create map
			create_map();
		<%

		String key = "empty";
		String distance = "20";

    		javax.servlet.http.Cookie[] cookies = request.getCookies();

    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		Properties prop = new Properties();
		prop.setProperty("consumer.key","12345");
		prop.setProperty("consumer.secret","67890");
		Scribe scribe = new Scribe(prop);

		PersistenceManager pm = PMF.get().getPersistenceManager();

		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");

		Request APIrequest;
		Response APIresponse;
		String API_URL ="";

		if (!key.equals("empty")) {
			try {
				List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					API_URL = "http://api.meetup.com/ew/events.json/?urlname=muntest&lat=" + users.get(0).getLat() + "&lon=" + users.get(0).getLon() + "&radius=" + distance;
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

			API_URL = "http://api.meetup.com/ew/events?status=upcoming%2Cpast&radius=20.0&order=time&urlname=muntest&format=json&lat=34.0999984741&page=200&zip=90210&offset=0&lon=-118.410003662&sig_id=12219924&sig=672837c2e23e6c5fefa86c29e0f6ad51";
			APIrequest = new Request(Request.Verb.GET, API_URL);
			APIresponse = APIrequest.send();
			%>var data = <%=APIresponse.getBody().toString()%><%
	
		}
		%>
		
		events.empty();
		$.each(data.results, function(i, ev) {
			if (ev.lon != ''){
				
				random_offset = (2*Math.random() - 1)/500;
				random_offset2 = (2*Math.random() - 1)/500;
				//create new point for each event and extend map bounds to include it
				point = new google.maps.LatLng(parseFloat(ev.lat) + random_offset, parseFloat(ev.lon) + random_offset2);
				bounds.extend(point);
				var marker = new google.maps.Marker({ 
					position: point,
					map: map,
					title: ev.container.name, 
				});
				var date = new Date(ev.time);
				var date_string = date.getMonth() + "/" + date.getDate() + "/" + date.getFullYear() + " " + date.getHours() + ":";
				if (date.getMinutes() < 10) {
					date_string = date_string + "0" + date.getMinutes();
				} else{
					date_string = date_string + date.getMinutes();
				}		

				events.append('<a href="javascript:topic_show(' + ev.id + ')" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> ' + date_string + ' </span><span class="mn_geoListItem_where"> ' + ev.city + ' </span><span class="mn_geoListItem_title"> ' + ev.container.name + ' </span></span></a>');

				//provide link for each point with event info
				google.maps.event.addListener(marker, 'click', function() {
					
					var link = '<b><a href="' + ev.meetup_url + '" style="color:Blue">' + ev.container.name + '</a></b><br>WHERE: ' + ev.venue_name + '<br>WHEN: ' + date_string + '<br>';
						
					var win = new google.maps.InfoWindow({
						content: link,
					});
						win.open(map, marker);
				});

				event_object = new Object;
				event_object.id = ev.id;
				event_object.description = ev.description;
				event_object.marker = marker;
	
				eventArray.push(event_object);						
			}
		});
	
		events.append('<a href="javascript:topic_show(-1)" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> Show All </span><span class="mn_geoListItem_where">  </span><span class="mn_geoListItem_title">  </span></span></a>');

		//fit map and set loc to adress
		map.fitBounds(bounds);

	}

	</script>
</head>
<body id="meetupNowBody" onload="use_everywhere()">
	
<div id="mew_header">
	<div id="mew_headerBody">
		<div id="mew_logo">
			<a href="http://www.meetup.com/everywhere">
				<img src="images/meetup_ew.png" alt="Meetup" style="width: auto !important; height: auto !important">
			</a>
		</div><!-- mew_logo -->
		<div id="mew_userNav">
<%

		if (key.equals("empty")) {
%>
<a href="/oauth">Log In</a>
<%
		} else {
			//FIND USER			

		
			try {
				List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
					
%>
<p><%=users.get(0).getName()%>
<a href ="/logout?callback=">LOGOUT</a></p>
<%
			} finally {
				query.closeAll();
			}
		}
%>
</div>
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
								<img src="images/mn_banner2.png" alt="Meetup Now">
							</div>
							<div class="d_boxSection">
								<div id="d_boxContent">
									
									<div id="d_boxContentRight">
										<div id="mn_description">
											<span class="subtitle"></span>
											<span class="subtitle">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua?</span>
											<span class="title">Lorem ipsum!</span>
											<span class="button_start">Get Started!</span>
										</div><!-- mn_description -->
										<div id="mn_eventDescription">
												<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
										</div><!-- mn_eventDescription -->

									</div><!-- d_boxContentRight -->
									
									<div id="d_boxContentLeft">
										<div class="map_context">
											<span class="map_title title">Happening NOW near you...</span>
											<div id="map_canvasContainer">
												<div id="map_canvas">
										
												</div><!-- map_canvas -->
											</div><!-- map_canvasContainer -->
										</div><!-- map_context -->
										<div id="mn_geoListContext">
											<div id="mn_geoListHeader">
												<span>Today in Sports<span>
											</div><!-- mn_geoListHeader -->
											
											<div id="mn_geoListFooter">
										
											</div><!-- mn_geoListFooter -->
										</div><!-- mn_geoListContext -->
									</div><!-- d_boxContentLeft -->
								</div><!-- d_boxContent -->
							</div><!-- d_boxSection -->
						</div><!-- d_boxBody -->
					</div><!-- d_box -->
				</div><!-- mn_box -->
			</div><!-- mn_document -->
		</div><!-- mn_context -->
		<a href="/MeetupNow">Meetup Now</a>
	</div><!-- mn_pageBody -->
</div><!-- mn_page -->
	<a href="/MeetupNow">Meetup Now</a><br>
	<a href="/MUNTest.jsp">API test call</a><br>
	<a href="/CreateEvent.jsp">Create Event</a>
</body>
</html>
