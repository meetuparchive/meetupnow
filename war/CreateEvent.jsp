<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.Topic" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now - Create An Event</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<link rel="stylesheet" href="/css/ui-lightness/jquery-ui-1.8.2.css" type="text/css" />
	<link rel="stylesheet" type="text/css" media="all" href="css/grids.css">
	
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
	<script type="text/javascript">
	
	var error = new Date();
	var slidertime = new Date();
	var nowtime = new Date(); // Variable to keep current time
	
	// Jump slider to current time positon
	function today(){
		var currentMinTime = getMinTime();
		$("#slider").slider("value", currentMinTime.getTime());
		$("#amount").val(getFormattedTime(currentMinTime.getHours(),currentMinTime.getMinutes()) + " " + getFormattedMonth(currentMinTime.getMonth()) +" "+ currentMinTime.getDate());
	}
	
	// Jump slider to beginning of tomorrow position
	function tomorrow(){
		var currentMinTime = getMinTime();
		currentMinTime.setHours(0);
		currentMinTime.setMinutes(0);
		currentMinTime.setSeconds(0);
		
		var tomorrowtime = new Date();
		tomorrowtime.setTime(currentMinTime.getTime() + 86400000);
		
		$("#slider").slider("value", tomorrowtime.getTime());
		$("#amount").val(getFormattedTime(tomorrowtime.getHours(),tomorrowtime.getMinutes()) + " " + getFormattedMonth(tomorrowtime.getMonth()) +" "+ tomorrowtime.getDate());
	}
	
	function getTomorrowDate() {
		var currentMinTime = getMinTime();
		currentMinTime.setHours(0);
		currentMinTime.setMinutes(0);
		currentMinTime.setSeconds(0);

		var tomorrowtime = new Date();
		tomorrowtime.setTime(currentMinTime.getTime() + 86400000);
		
		tomorrowDate = tomorrowtime.getDate();
		return tomorrowDate;
	}
	
	function verifyAddress() {
		var add = $('#address');
		var out = $('#out');
		var geocoder = new google.maps.Geocoder();
		var lat;
		var lon;
		var address;

		if(geocoder){
			geocoder.geocode( { 'address': add.val()}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					var ad_out = "";
					var city_out = "";
					var state_out = "";
					var country_out = "";
					var zip_out = "";
					document.getElementById('lat').value = results[0].geometry.location.lat();
					document.getElementById('lon').value = results[0].geometry.location.lng();
					address = results[0].formatted_address;
					
					var k;
					var t;
					for (k = 0; k < results[0].address_components.length; k++) {
						var temp = results[0].address_components[k];
						for (t = 0; t < temp.types.length; t++) {
							if (temp.types[t] == "street_number") {
								ad_out = ad_out + temp.long_name+" ";	
							}
							if (temp.types[t] == "route") {
								ad_out = ad_out + temp.long_name+" ";
							}
							if (temp.types[t] == "subpremise") {
								ad_out = ad_out +"#"+ temp.long_name+", ";
							}
							if (temp.types[t] == "locality") {
								city_out = temp.long_name;
							}
							if (temp.types[t] == "administrative_area_level_1") {
								state_out = temp.long_name;
							}
							if (temp.types[t] == "country") {
								country_out = temp.long_name;
							}
							if (temp.types[t] == "postal_code") {
								zip_out = temp.long_name;
							}
						}
					}

					document.getElementById('ad').value = ad_out;
					document.getElementById('city').value = city_out;
					document.getElementById('state').value = state_out;
					document.getElementById('country').value = country_out;

							
					out.empty();
					out.append("<span style='color:green; font-size:1.4em; font-weight:bold;'>&#10003;</span>");
					addressCheck = true;
				} else {
					out.empty();
					out.append("<span style='color:red; font-size:1.4em; font-weight:bold;'>X</span>");
					addressCheck = false;
					
				}
				
			});
		}
	}
	
	function getFormattedMonth(m) {
			switch (m)
			{
			case 0:
		  		return ("Jan");
			case 1:
				return ("Feb");		
			case 2:
		  		return ("Mar");
			case 3:
				return ("Apr");
			case 4:
				return ("May");
			case 5:
				return ("Jun");
			case 6:
				return ("Jul");
			case 7:
				return ("Aug");
			case 8:
				return ("Sep");
			case 9:
				return ("Oct");
			case 10:
				return ("Nov");
			case 11:
				return ("Dec");
			default:
				return ("Undef");
			}
	}
	
	function getFormattedTime(h, m) {
		var ampm = "AM";

		if (h >= 12) {ampm = "PM";}
		if (h > 12) { h = h - 12;}
		if (h == 0) {h = 12;}
		if (m > 9) { return (h + ":" + m + " " + ampm);}
		else {return (h + ":0" + m + " " + ampm);}
	}
	
	function getMinTime() {
		var now = nowtime.getTime();
		var now_hour = nowtime.getHours();
		var now_minutes = nowtime.getMinutes();
		
		if ( ( now_minutes / 60 ) <= .25 ) {
			minMinute = .25;
		} else if ( ( now_minutes / 60 ) <= .5 ) {
			minMinute = .5;
		} else if ( ( now_minutes / 60 ) <= .75) {
			minMinute = .75;
		} else if ( ( now_minutes / 60 ) <= 1) {
			minMinute = 0;
			now_hour = now_hour + 1;
		}
		
		minTime = new Date();
		minTime.setHours( now_hour );
		minTime.setMinutes( minMinute * 60 );
		minTime.setSeconds( 0 );
		
		return minTime;
	}
	
	function getMaxTime() {
		
		var max = getMinTime();
		max.setHours(0);
		max.setMinutes(0);
		max.setSeconds(0);
		max.setTime( max.getTime() + (172800000-300000) );
		//maxTime = max.getTime() - 300000;
		
		maxTime = new Date();
		maxTime.setTime(max.getTime());
		return maxTime;
	}
	
	function passValues( timeobj ) {
		document.getElementById('localTimeZone').value = timeobj.getTimezoneOffset()/60;
		document.getElementById('year').value = timeobj.getFullYear();
		document.getElementById('month').value = timeobj.getMonth()+1;
		document.getElementById('day').value = timeobj.getDate();
		document.getElementById('minute').value = timeobj.getMinutes();
		
		if ( timeobj.getHours() > 12 ) {
			//var format_hour = timeobj.getHours() - 12;
			var format_ampm = "PM";
		} else if ( timeobj.getHours() == 12 ) {
			var format_hour = timeobj.getHours();
			var format_amppm = "PM"
		}
		else {
			var format_hour = timeobj.getHours();
			var format_ampm = "AM";
		}
		document.getElementById('ampm').value = format_ampm;
		document.getElementById('hour').value = format_hour;
		document.getElementById('epochtime').value = timeobj.getTime();
	}
	
	$(function() {
		verifyAddress();
	});
	
	$(function() {
		// Initialize jQuery UI button
		$("#radio_when").buttonset();
	});
	
	$(function() {
		// Date/Time picker slider
		// Pass values to form for post
		passValues( getMinTime() );
		
		$("#slider").slider({
		value: getMinTime().getTime(),
		min: getMinTime().getTime(),
		max: getMaxTime().getTime(),
		step: 300000,
		slide: function(event, ui) {
				//$("#amount").val('$' + ui.value);
				slidertime.setTime(ui.value);
				$("#amount").val(getFormattedTime(slidertime.getHours(),slidertime.getMinutes()) + " " + getFormattedMonth(slidertime.getMonth()) +" "+ slidertime.getDate());

				if ( slidertime.getDate() >= getTomorrowDate() ) {
					//document.getElementById('radio1').checked = false;
					document.getElementById('radio2').checked = true;
					$("#radio2").button('refresh');
					$("#amount").val(getFormattedTime(slidertime.getHours(),slidertime.getMinutes()) + " " + getFormattedMonth(slidertime.getMonth()) +" "+ slidertime.getDate());
				}
				if ( slidertime.getDate() < getTomorrowDate() ) {
					document.getElementById('radio1').checked = true;
					$("#radio1").button('refresh');
					$("#amount").val(getFormattedTime(slidertime.getHours(),slidertime.getMinutes()) + " " + getFormattedMonth(slidertime.getMonth()) +" "+ slidertime.getDate());
				}
				
				passValues( slidertime );
			}
		});
		
		var initAmount = getMinTime();
		$("#amount").val(getFormattedTime(initAmount.getHours(),initAmount.getMinutes()) + " " + getFormattedMonth(initAmount.getMonth()) +" "+ initAmount.getDate());
		
	});

	var addressCheck = false;

	function verifySubmission() {

		var now_ampm = document.getElementById('ampm').value;
		var now_hour = document.getElementById('hour').value;
		var canSubmit = true;
		var message = "";

		if (document.getElementById('topic').value == "") {
			message = message + "Please select a topic for your event\n";
			canSubmit = false;
		}

		if (document.getElementById('title').value == "") {
			message = message + "Please enter a title for your event\n";
			canSubmit = false;
		}
		if (document.getElementById('venue').value == "") {
			message = message + "Please pick a venue\n";
			canSubmit = false;
		}
		if ((document.getElementById('hour').value == "")||(document.getElementById('minute').value == "")) {
			message = message + "Please pick a time\n";
			canSubmit = false;
		}

		if (document.getElementById('desc').value == "") {
			message = message + "Please enter a description\n";
			canSubmit = false;
		}

		if (document.getElementById('address').value == "") {
			message = message + "Please enter an address\n";
			canSubmit = false;
		}

		if (!addressCheck) {
			message = message + "Enter a valid Address";
			canSubmit = false;
		}
	
		if((parseInt(document.getElementById('year').value) - 1900) < error.getYear()) {
			message = message + "Please enter a date in the future\n";
			canSubmit = false;
		} else if ((parseInt(document.getElementById('year').value) - 1900) == error.getYear()){
			if ((parseInt(document.getElementById('month').value) - 1) < error.getMonth()) {
				message = message + "Please enter a date in the future\n";
				canSubmit = false;
			} else if ((parseInt(document.getElementById('month').value) - 1) == error.getMonth()){
				if (parseInt(document.getElementById('day').value) < error.getDate()) {
					message = message + "Please enter a date in the future\n";
					canSubmit = false;
				} else if (parseInt(document.getElementById('day').value) == error.getDate()){
					if (document.getElementById('ampm').value == "am") {
						if (now_ampm == "pm") {
							message = message + "Please enter a time in the future\n";
							canSubmit = false;
						}
						else if (parseInt(document.getElementById('hour').value) < now_hour) {
							message = message + "Please enter a time in the future\n";
							canSubmit = false;
						} else if (parseInt(document.getElementById('hour').value) == now_hour) {
							if (parseInt(document.getElementById('minute').value) < error.getMinutes() ) {
								message = message + "Please enter a time in the future\n"
								canSubmit = false;
							}
						}
					} else  { //pm
						if (now_ampm == "pm") {
							if (parseInt(document.getElementById('hour').value) < now_hour) {
								message = message + "Please enter a time in the future\n";
								canSubmit = false;
							} else if (parseInt(document.getElementById('hour').value) == now_hour) {
								if (parseInt(document.getElementById('minute').value) < error.getMinutes() ) {
									message = message + "Please enter a time in the future\n"
									canSubmit = false;
							}
						}
							
						}
					}
				}
			}
		}

		if (canSubmit) {
			return true;
		} else {
			alert(message);
			return false;
		}
	}

</script>
</head>
<body>
	
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>

<div id="wrap">
	
	<%@ include file="jsp/header.jsp" %>
<%
	String c_id = "";
	
	if (request.getQueryString() != null) {
		c_id = request.getQueryString();
	}
%>
	<div id="main">
		<div id="contentBottom">
			<div id="contentBottomBody">
				<span class="title">Create An Event</span>
			<div class="line">
			<div class="unit size3of5">
				<form id="form_createEvent" name="f" action="/EventCreate" onSubmit="return verifySubmission()" method="get">
				
				<%
					Query TopicQuery = pm.newQuery(Topic.class);
					TopicQuery.setFilter("id != 0");
					TopicQuery.declareParameters("String reqTokenParam");	//Setup Query

					List<Topic> topics = (List<Topic>) TopicQuery.execute(key);
				%>
				
					<frameset>
					<legend><span class="hidden">Event Title</span></legend>
					<ul>
					<li>
						<label for="title">Event Title</label>
						<input type="text" value="" name="name" id="title">
					</li>
					<li>
						<label for="topic" class="hidden">Select Topic</label> 
						<select id="topic" name="topic">
							<option value="">-Select A Topic-</option>
							
				<%
						String tString;
						for (int i = 0; i < topics.size(); i++) {
							tString = ""+topics.get(i).getId();
							if (tString.equals(c_id)) {
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
					</li>
					</ul>
					</frameset>
					
					<frameset>
					<legend><span class="hidden">When</span></legend>
					<ul id="radio_when">
						<li>
							<label for="amount">Event Time</label>
							<input type="radio" id="radio1" name="radio" checked="true" onclick=today()><label for="radio1">Today</label>
							<input type="radio" id="radio2" name="radio" onclick=tomorrow()><label for="radio2">Tomorrow</label>
							<input type="text" id="amount" style="border:0; color:#f6931f; font-weight:bold;" />

							<div id="slider"></div>
						</li>
					</ul>
					</frameset>
					
					<frameset>
					<legend><span class="hidden">Where</span></legend>
					<ul>
						<li>
							<label for="venue">Venue</label>
							<input type="text" name="venue" id="venue">
						</li>
						<li>
							<label for="address">Address or Zip Code</label>
							<input type="text" name="address" id="address" onChange="verifyAddress()" onKeyDown="verifyAddress()" onBlur="verifyAddress()">
							<div id="out"></div>
						</li>
					</ul>
					</frameset>
			</div><!-- end .unit .size3of5 -->
			<div class="unit size2of5 lastUnit">
					<frameset>
					<legend><span class="hidden">Description</span></legend>
					<ul>
						<li>
							<label for="desc">Description</label>
							<textarea name="desc" id="desc"></textarea>
						<li>
					</ul>
					</frameset>
			</div><!-- end .unit .size2of5 .lastUnit -->
			</div><!-- end .line -->
					<input type="hidden" name="month" id="month" />
					<input type="hidden" name="day" id="day" />
					<input type="hidden" name="year" id="year" />
					<input type="hidden" name="hour" id="hour" />
					<input type="hidden" name="minute" id="minute" />
					<input type="hidden" name="ampm" id="ampm" />
					<input type="hidden" name="localTimeZone" id="localTimeZone" />
					<input type="hidden" name="lat" value="NA" id="lat" />
					<input type="hidden" name="lon" value="NA" id="lon" />
					<input type="hidden" name="epochtime" id="epochtime" />
					<input type="hidden" name="ad" value="NA" id="ad" />
					<input type="hidden" name="country" value="NA" id="country" />
					<input type="hidden" name="city" value="NA" id="city" />
					<input type="hidden" name="state" value="NA" id="state" />
					<input type="hidden" name="callback" value="/Event" />
					<input type="submit" id="exe" value="Create" class="actionBtn createBtn">

				</form>
			
			</div> <!-- end #contentBottomBody -->
		</div> <!-- end #contentBottom -->
	</div> <!-- end #main -->
</div> <!-- end #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>
