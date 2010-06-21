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
</head>
<body onload="initialize()">
<div id="mn_superHeader">
	<div id="mn_superHeaderBody">
		<div id="mn_superHeader_logo">
			<a href="#">
				<img src="images/mnlogo_sm_white.png" alt="MeetupNow" style="width: auto !important; height: auto !important">
			</a>
		</div> <!-- end #mn_superHeader_logo -->
		<div id="mn_superHeader_usernav">
			<ul>
				<li><a href="/oauth">Log In</a></li>
				<li><a href="#">Settings</a></li>
				<li><a href="#">User Logged In</a></li>
			</ul>
		</div> <!-- end mn_superHeader_usernav -->
	</div> <!-- end #mn_superHeaderBody -->
</div> <!-- end #mn_superHeader -->
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
				<form action="search" method="get" accept-charset="utf-8">
					<label for="query">Search for: </label><input type="text/submit/hidden/button" name="query" value="" id="query">
					<label for="location"></label>City or ZIP / Postal Code<input type="text/submit/hidden/button" name="location" value="" id="location">
					
					<p><input type="submit" value="Search"></p>
				</form>
			</div> <!-- end #search -->
		</div> <!-- end #searchContext -->
		<div id="mn_geoListContext">
			<div id="mn_geoListHeader">
				<span>Today in Sports<span>
			</div><!-- mn_geoListHeader -->
			<a href="#" class="mn_geoListItem_link">
				<span class="mn_geoListItem">
					<span class="mn_geoListItem_date">6/16</span>
					<span class="mn_geoListItem_time">1:00 pm</span>
					<span class="mn_geoListItem_where">New York, NY</span>
					<span class="mn_geoListItem_title">Flag Football</span>
				</span>
			</a>
			<a href="#" class="mn_geoListItem_link">
				<span class="mn_geoListItem">
					<span class="mn_geoListItem_date">6/17</span>
					<span class="mn_geoListItem_time">5:30 pm</span>
					<span class="mn_geoListItem_where">Brooklyn, NY</span>
					<span class="mn_geoListItem_title">Rugby</span>
				</span>
			</a>
			<div id="mn_geoListFooter">
		
			</div><!-- mn_geoListFooter -->
		</div><!-- mn_geoListContext -->
	</div> <!-- end #contentRight -->
	<div id="contentLeft">
		
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->
</div> <!-- end #wrapper -->
</body>
</html>