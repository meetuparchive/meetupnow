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

<html>
<head>
<style type="text/css">
	.MEETUP_WIDGET{
		background: #1a1a1a;
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		width: 800px;
		font-family: verdana, sans-serif;
	}
	.MEETUP_WIDGET_body{
		padding: 8px;
	}
	.MEETUP_WIDGET_total a{
		display: block;
		color: #fff;
		text-decoration: none;
	}
	.MEETUP_WIDGET a img{
		border: 0!important;
	}
	.MEETUP_WIDGET_total a img{
		margin: 4px 0;
	}
	.MEETUP_WIDGET_title{
		display: block;
		font-family: arial, sans-serif;
		font-weight: bold;
		letter-spacing: -1px;
		line-height: 1.2em;
	}
	.MEETUP_WIDGET_total .MEETUP_WIDGET_title{
		font-size: 22px;
	}
	.MEETUP_WIDGET_name{
	}
	.MEETUP_WIDGET_logo{
		display: block;
		text-align: left;
	}
	.MEETUP_WIDGET_people{
		font-size: 12px;
		display: block;
	}
	.MEETUP_WIDGET_suffix{
		color: #aaa;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_title{
		font-size: 14px;
		color: #aaa;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_nearby_list{
		-moz-border-radius: 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px;
		display: block;
		background: #333;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_nearby_list a{
		zoom: 1;
		border-top: 1px solid #1a1a1a!important;
		padding: 8px 10px;
		display: block;
		font-size: 12px;
		color: #fff;
		text-decoration: none;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_nearby_list a:after{
		content: ".";
		display: block;
		height: 0;
		clear: both;
		visibility: hidden;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_nearby_list a:hover{
		background: #a3e4ff;
		color: #3c3633 !important;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_nearby_list a{
		padding: 6px 10px;
	}
	.MEETUP_WIDGET_nearby .MEETUP_WIDGET_nearby_list a .MEETUP_WIDGET_all{
		display: block;
		text-align: right;
		display: block;
		font-family: arial, sans-serif;
		font-weight: bold;
		/*
		text-transform: lowercase;
		font-variant: small-caps;
		*/
		font-size: 11.399999999999999px;
	}
	.MEETUP_WIDGET_bottom_logo{
		margin-top: 8px;
	}
	.MEETUP_WIDGET_nearby a .when{
		display: block;
		float: left;
		width: 4em;
		text-align: right;
	}
	.MEETUP_WIDGET_nearby a .loc{
		margin-left: 4.35em;
		padding-left: .35em;
		border-left: 1px dotted #555;
		display: block;
	}
	.MEETUP_WIDGET_nearby a .loc .city{
		font-weight: bold;
	}
	.MEETUP_WIDGET_nearby a .when .time,
	.MEETUP_WIDGET_nearby a .loc .address{
		font-size: 10.2px;
		display: block;
	}
	.MEETUP_WIDGET_go{
		background-color: #ca3e47;
		background-image: -moz-linear-gradient(top, #ca3e47, #a8252e);
		background-image: -webkit-gradient(linear,left bottom,left top,color-stop(0, #a8252e),color-stop(1, #ca3e47));
		filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ca3e47', endColorstr='#a8252e');
		border: 2px solid #a8252e;
		-moz-border-radius: 4px 4px 4px 4px;
		-webkit-border-radius: 4px;
		border-radius: 4px 4px 4px 4px;
		text-shadow: black 0px 0px 2px;
		zoom: 1;
		display: inline;
		display: inline-block;
		text-align: center;
		font-weight: bold;
		font-size: 15px;
		margin-left: 2px;
		line-height: .75em;
		color: #fff!important;
		font-family: arial;
		padding: 0px 4px;
		cursor: pointer;
		cursor: hand;
	}
	.MEETUP_WIDGET_map{
		a:link {text-decoration: none}
		a:visited {text-decoration: none}
		a:active {text-decoration: none}
		a:hover {text-decoration: underline; color: red;}
	}
</style>

<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script>


function create_map(){
		map = new google.maps.Map(document.getElementById("map_canvas"), {
      		zoom: 15,
      		center: new google.maps.LatLng(0,0),
      		mapTypeId: google.maps.MapTypeId.ROADMAP
    	});
}

function use_everywhere(){
	

	var bounds = new google.maps.LatLngBounds();
	var geocoder = new google.maps.Geocoder();
	
	var zip = $('#zipcode');
	var dist = $('#distance');
	var loc = $('#city');
	var topic = $('#topics');
	topic.empty();
	var topic_title = $('#topics_title');
	topic_title.empty();
		
	//clear location
	loc.empty();
		
	//create map
	create_map();
		
	if (geocoder) {
		geocoder.geocode({
			'address': zip.val()
		}, function(results, status){					
			if (status == google.maps.GeocoderStatus.OK) {
						
				//if geocoder status ok them save lat, lng, and adress
				zip_lat = results[0].geometry.location.lat();
				zip_lon = results[0].geometry.location.lng();
				adress = results[0].formatted_address;
<%
		String key = "empty";
    		Cookie[] cookies = request.getCookies();
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
			response.sendRedirect("/test");
		}	
		
		Properties prop = new Properties();
		prop.setProperty("consumer.key","12345");
		prop.setProperty("consumer.secret","67890");
		Scribe scribe = new Scribe(prop);
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");
		try {
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			if (users.iterator().hasNext()) {
				Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
				Request APIrequest = new Request(Request.Verb.GET, 'http://api.meetup.com/ew/events.json/?lat=' + %>zip_lat<% + '&lon=' + %>zip_lon<% + '&radius=' + %>dist.val();<%
				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				JSONObject json = new JSONObject();
				JSONArray results;
				try {
					json = new JSONObject(APIresponse.getBody());
					results = json.getJSONArray("results");
					String[] names = JSONObject.getNames(results.getJSONObject(0));
					for (int j = 0; j < results.length(); j++) {
						JSONObject item = results.getJSONObject(j);
					}
				} catch (JSONException j) {
		
				}
			}
		}
		finally {
			query.closeAll();
		}
%>				



				//query meetup api		
				var ev_query = 'http://api.meetup.com/ew/events.json/?lat=' + zip_lat + '&lon=' + zip_lon + '&radius=' + dist.val();
				$.getJSON(ev_query, function(data){
							
					//handle error
					if (data.status && data.status.match(/^200/) == null) {
						alert(data.status + ": " + data.details);
					} else {
						
						$.each(data.results, function(i, ev) {
							if ((ev.lon != '') && (ev.venue_name != undefined)){
		
								random_offset = (2*Math.random() - 1)/500;
								random_offset2 = (2*Math.random() - 1)/500;
								//create new point for each event and extend map bounds to include it
								point = new google.maps.LatLng(parseFloat(ev.lat) + random_offset, parseFloat(ev.lon) + random_offset2);
								bounds.extend(point);
								var marker = new google.maps.Marker({ 
									position: point,
									map: map,
									title: ev.name, 
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
												
									var comment_query = 'http://api.meetup.com/ew/comment.json/?event_id=' + ev.id + '&key=' + api_key.val() + '&callback=?';
									/*$.getJSON(comment_query, function(dat){
										$.each(dat.results, function(j, ev2) {
											link = link + com.member.name + ": " + com.comment;	
										});
									});*/
					 		     		var win = new google.maps.InfoWindow({
						  	      			content: link,
						  	    		});
						    			win.open(map, marker);
								});	
										
							}
			 			});
	
						//fit map and set loc to adress
						map.fitBounds(bounds);
						loc.append(adress);
					}
				});
			}
		});
	}
}
</script>

</head>
<body>
<a href="/oauth?callback=FindEvent.jsp">LOGIN</a>

<form name="submitform">
	Location <input type="text" id="zipcode" />
	<br>
	Radius <input type="text" id="distance" />

	<input type="button" value="Show Map!" onclick="use_everywhere()" />
	<br>
</form>

<div id="MEETUP_WIDGET_28" class="MEETUP_WIDGET">
	<div class="MEETUP_WIDGET_body">
		<div class="MEETUP_WIDGET_total">

				<span class="MEETUP_WIDGET_title">

					<span class="MEETUP_WIDGET_name"> </span>
					<span class="MEETUP_WIDGET_suffix"> 
						<div id="title"></div>
						<div id="city"></div>
					</span>
				</span>

			
				<div class="MEETUP_WIDGET_map" id="map_canvas" style="width:100%; height:75%"></div>
			
		</div>
		<div class="MEETUP_WIDGET_nearby">
			<div class="MEETUP_WIDGET_title" id="topics_title">
			
			</div>
			<div class="MEETUP_WIDGET_nearby_list" id="topics">
				
				
			</div>
		</div>
		<a href="http://www.meetup.com/" class="MEETUP_WIDGET_logo">
			<img src="http://img1.meetupstatic.com/84869143793177372874/img/birddog/everywhere_widget.png" class="MEETUP_WIDGET_bottom_logo"  />
		</a>
	</div>
</div>

</head>
</html>
