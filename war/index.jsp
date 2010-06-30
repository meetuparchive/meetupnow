<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="meetupnow.RegDev" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
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

		
			function loadEvents(){
			<%@ include file="jsp/cookie.jsp" %>
			<%@ include file="jsp/declares.jsp" %>

			<%@ page import="meetupnow.Topic" %>
			<%


			API_URL = "http://api.meetup.com/ew/containers?order=name&offset=0&link=http%3A%2F%2Fjake-meetup-test.appspot.com";
			RegDev sg = new RegDev();
			APIresponse = sg.submitURL(API_URL);
			JSONObject json;
			JSONArray top_list;	
			String Lat = "";
			String Lon = "";

		
			String TopicList = "container_id=654,713,";
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

			try{
				json = new JSONObject(APIresponse.getBody());
				top_list = json.getJSONArray("results");
				boolean found = false;

				for (int j = 0; j < top_list.length(); j++){
					found = false;
					for (int i = 0; i < Topics.size(); i++){
						if( Integer.parseInt(top_list.getJSONObject(j).getString("id")) == Topics.get(i).getId() ){
							found = true;
						}
					}
					if (!found){

						NewTopic = new Topic(top_list.getJSONObject(j).getString("description"), top_list.getJSONObject(j).getJSONObject("founder").getString("member_id"), top_list.getJSONObject(j).getString("name"), Integer.parseInt(top_list.getJSONObject(j).getString("id")));
						try {
							pm.makePersistent(NewTopic);
						} 
				
						finally {

						}
					}
				}

			}
			catch (JSONException j){

			}

			if (!key.equals("empty")) {
				try {
					users = (List<MeetupUser>) query.execute(key);
					if (users.iterator().hasNext()) {
						Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
						API_URL = "http://api.meetup.com/ew/events/?status=upcoming&" + TopicList + "&lat=" + users.get(0).getLat() + "&lon=" + users.get(0).getLon() + "&radius=" + distance;
						Lat = users.get(0).getLat();
						Lon = users.get(0).getLon();
						APIrequest = new Request(Request.Verb.GET, API_URL);
						scribe.signRequest(APIrequest,accessToken);
						APIresponse = APIrequest.send();
						%>data = <%=APIresponse.getBody().toString()%><%
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
				API_URL = "http://api.meetup.com/ew/events?status=upcoming&lat=" + Lat + "&lon=" + Lon + "&radius=25.0&order=time&"+TopicList;
				APIresponse = sg.submitURL(API_URL);
				%>var data = <%=APIresponse.getBody().toString()%><%
	
			}
		
			String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?latlng=" + Lat + "," + Lon +"&sensor=true";
			APIresponse = sg.submitURL(GEOCODE_API_URL);
			%>var geocode = <%=APIresponse.getBody().toString()%>
				var location = geocode.results[0].address_components[2].long_name;

				$('#listTitleLoc').append(location);
				use_everywhere(data);
			}

	</script>
</head>
<body onload="loadEvents()">
<div id="wrap">
	
<%@ include file="jsp/header.jsp" %>

<%//@ include file="jsp/ticker.jsp" %>
<div id="main">
	<div id="contentRight">
		<div id="contentRightBody">
			<div class="map_contextRight">
				<span class="map_title title">Happening NOW near you...</span>
				<div id="map_canvasContainerRight">
					<div id="map_canvas">
		
<<<<<<< HEAD:war/index.jsp
				</div><!-- end #map_canvas -->
			</div><!-- end #map_canvasContainer -->
		</div><!-- end .map_context -->
		<div id="searchContext">
			<div id="search">
				<form action="searchresult.jsp" method="post" accept-charset="utf-8">
					<div class="element">
						<div class="label">
							<label for="query">Search for: </label>
						</div> <!-- end .label -->
						<div class="mainSearchInput">
							<input type="text" name="query" value="" id="mainSearchQuery" maxlength="100">
						</div> <!-- end .input -->
					</div> <!-- end .element -->
					<div class="element">
						<div class="label">
							<label for="location">City or Postal Code</label>
						</div> <!-- end .label -->
						<div class="mainSearchInput">
							<input type="text" name="location" value="" id="mainSearchLocation" maxlength="100">
						</div> <!-- end .input -->
					</div> <!-- end .element -->

						<div class="submit">
							<input type="submit" value="Search" class="submitBtn">
						</div> <!-- end .submit -->
				</form>
			</div> <!-- end #search -->
			<span class="subtitle" style="clear:both;"><a href="/search.jsp">Go to Topic Search</a></span>
		</div> <!-- end #searchContext -->
		<div id="mn_geoListContext">
			<div id="mn_geoListHeader">
				<span class="listTitle">Results near <div id="listTitleLoc"></div></span>
			</div><!-- mn_geoListHeader -->
			<div id="mn_geoListBody">
=======
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
							<div class="mainSearchInput">
								<input type="text" name="query" value="" id="mainSearchQuery" maxlength="100">
							</div> <!-- end .input -->
						</div> <!-- end .element -->
						<div class="element">
							<div class="label">
								<label for="location">City or Postal Code</label>
							</div> <!-- end .label -->
							<div class="mainSearchInput">
								<input type="text" name="location" value="" id="mainSearchLocation" maxlength="100">
							</div> <!-- end .input -->
						</div> <!-- end .element -->

							<div class="submit">
								<input type="submit" value="Search" class="submitBtn">
							</div> <!-- end .submit -->
					</form>
				</div> <!-- end #search -->
				<span class="subtitle" style="clear:both;"><a href="/search.jsp">Go to Topic Search</a></span>
			</div> <!-- end #searchContext -->
			<div id="mn_geoListContext">
				<div id="mn_geoListHeader">
					<span class="listTitle">Results near <div id="listTitleLoc"></div></span>
				</div><!-- mn_geoListHeader -->
				<div id="mn_geoListBody">
>>>>>>> 0c9a906a97922fc5e5f5cffde96baeaf3f738564:war/index.jsp
				
				</div> <!-- end #mn_geoListBody -->
				<div id="mn_geoListFooter">
					<div id="searchResultsNav">
						<span class="showAll"></span>
						<span class="paginationNav"></span>
					</div> <!-- end searchResultsNav -->
				</div><!-- mn_geoListFooter -->
			</div><!-- mn_geoListContext -->
		</div> <!-- end #contentRightBody -->
	</div> <!-- end #contentRight -->
	<div id="contentLeft">
		<div id="contentLeftBody">
			<span class="title">Get Started.</span>
			<div id="action">
				<a href="lucky"><span class="btn_main">Something Close and Soon</span></a>
				<a href="AllTopics.jsp"><span class="btn_main">Create Event</span></a>
				<a href="search.jsp"><span class="btn_main">Search Topics</span></a>
			</div> <!-- end #action -->
			<div id="actionDesc">
				<span class="heading">MeetupNow is a site built so that you can find events happening locally, and happening soon. Nothing going on near you? No problem, just start something yourself, and people nearby will hear about it. </span>
				<span class="heading">Now go out and do something.</span>
			</div> <!-- end #actionDesc -->
		</div> <!-- end #actionContext -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #main -->
</div> <!-- end #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>
