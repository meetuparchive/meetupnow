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
	



	function create_map(){
		map = new google.maps.Map(document.getElementById("map_canvas"), {
      			zoom: 15,
      			center: new google.maps.LatLng(0,0),
      			mapTypeId: google.maps.MapTypeId.ROADMAP
    		});
	}

	function use_everywhere(){

		<%

		String key = "empty";
		String callback = "";
		String zip = "";
		String distance = "";

    		javax.servlet.http.Cookie[] cookies = request.getCookies();

		
		if (request.getQueryString() != null) {
			callback = OAuthServlet.getArg("callback",request.getQueryString());
			zip = OAuthServlet.getArg("zip",request.getQueryString());
			distance = OAuthServlet.getArg("dist",request.getQueryString());
		}
		else{
			callback = "";
			zip = "10012";
			distance = "20";
		}
		
		String GEOCODE_URL = "http://maps.google.com/maps/api/geocode/json?address=" + zip + "&sensor=true";

    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
			response.sendRedirect("/oauth");
		}	
		
		Properties prop = new Properties();
		prop.setProperty("consumer.key","12345");
		prop.setProperty("consumer.secret","67890");
		Scribe scribe = new Scribe(prop);

		PersistenceManager pm = PMF.get().getPersistenceManager();

		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");

		JSONObject meetup_json = new JSONObject();

		try {
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			if (users.iterator().hasNext()) {
				Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
				Request APIrequest = new Request(Request.Verb.POST, GEOCODE_URL);
				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				JSONObject json = new JSONObject();
				try {
					json = new JSONObject(APIresponse.getBody());

					String[] names = JSONObject.getNames(json.getJSONArray("results").getJSONObject(0));

				
					String Lng = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");
					String Lat = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat");
					String API_URL = "http://api.meetup.com/ew/events.json/?urlname=muntest&lat=" + Lat + "&lon=" + Lng + "&radius=" + distance;

					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();

					%>var JSON_result= <%=APIresponse.getBody().toString()%><%
						
					
				} catch (JSONException j) {
		
				}
			}
		}
		finally {
			//query.closeAll();
			//response.sendRedirect(callback);
		}


		%>

			var bounds = new google.maps.LatLngBounds();

			//create map
			create_map();
			


		$.each(JSON_result.results, function(i, ev) {
			if (ev.lon != ''){
				
				random_offset = (2*Math.random() - 1)/500;
				random_offset2 = (2*Math.random() - 1)/500;
				//create new point for each event and extend map bounds to include it
				point = new google.maps.LatLng(parseFloat(ev.lat) + random_offset, parseFloat(ev.lon) + random_offset2);
				bounds.extend(point);
				var marker = new google.maps.Marker({ 
					position: point,
					map: map,
					//title: ev.name, 
				});
		
				//provide link for each point with event info
				google.maps.event.addListener(marker, 'click', function() {
					var date = new Date(ev.time);
					var date_string = date.getMonth() + "/" + date.getDate() + "/" + date.getFullYear() + " " + date.getHours() + ":";
					if (date.getMinutes() < 10) {
						date_string = date_string + "0" + date.getMinutes();
					} else{
						date_string = date_string + date.getMinutes();
					}
					var link = '<b><a href="' + ev.meetup_url + '" style="color:Blue">' + ev.container.name + '</a></b><br>WHERE: ' + ev.venue_name + '<br>WHEN: ' + date_string + '<br>';
						
					var win = new google.maps.InfoWindow({
						content: link,
					});
						win.open(map, marker);
				});
										
			}
		});
	
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
								<img src="images/mn_banner.png" alt="Meetup Now">
							</div>
							<div class="d_boxSection">
								<div id="d_boxContent">
										<div class="map_context">
											<!-- <span class="map_title title">Happening NOW near you...</span> -->
											<div id="map_canvasContainer">
												<div id="map_canvas">
										
												</div><!-- map_canvas -->
											</div><!-- map_canvasContainer -->
										</div><!-- map_context -->
										<div id="mn_description">
											<span class="subtitle">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua?</span>
											<span class="subtitle">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua?</span>
											<span class="title">Lorem ipsum!</span>

										</div><!-- mn_description -->
										<div id="mn_geoListContext">
											<div id="mn_geoListHeader">
												<span>Today in Sports<span>
											</div><!-- mn_geoListHeader -->
											<a href="#"><span class="mn_geoListItem">Flag Football</span></a>
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
		<a href="/MeetupNow">Meetup Now</a>
	</div><!-- mn_pageBody -->
</div><!-- mn_page -->
	<a href="/MeetupNow">Meetup Now</a><br>
	<a href="/MUNTest.jsp">API test call</a><br>
	<a href="/CreateEvent.jsp">Create Event</a>
</body>
</html>
