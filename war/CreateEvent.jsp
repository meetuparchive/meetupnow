<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script type="text/javascript">
	$(function() {
		var now = new Date();
		document.getElementById('month').value = now.getMonth()+1;
		document.getElementById('day').value = now.getDate();
	});

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
				
					document.getElementById('lat').value = results[0].geometry.location.lat();
					document.getElementById('lon').value = results[0].geometry.location.lng();
					address = results[0].formatted_address;

					out.empty();
					out.append(address+"<br>VALID");
					document.getElementById('exe').disabled = "";
				} else {
					out.empty();
					out.append("NOT VALID, TRY AGAIN");
				}
			});
		}

	}
</script>
</head>
<body id="meetupNowBody">
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>
<%@ include file="jsp/header.jsp" %>

<%

		String c_id = "";		
		if (request.getQueryString() != null) {
			c_id = request.getQueryString();
		}

		if (!key.equals("empty")) {

			try {
				users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/containers/?container_id="+c_id);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					JSONObject json = new JSONObject();
					JSONArray results;
					try {
						json = new JSONObject(APIresponse.getBody());
						results = json.getJSONArray("results");
%>

<div id="wrapper">
	<div id="wrapperContent">
		<div id="contentLeft">
			<div id="contentLeftContext">
<span class="title">Create An Event - Let's Meetup Now!</span><br>
<form name="f" action="/EventCreate" method="get">


	<span class="goLeft"><span class="heading"> Topic: </span></span>
	<span class="goRight"> <%=results.getJSONObject(0).getString("name")%> &nbsp | &nbsp <a href="/">Change Topic</a></span>
	<br><br><br><br>
	<span class="goLeft"><span class="heading"> Title: </span></span>
	<span class="goRight"><input type="text" name="name" /></span>
	<br><br><br><br><br>
	<span class="goLeft"><span class="heading"> When? </span></span>
	<span class="goRight">		
		<select id="month" name="month">
			<option value="1">January</option>
  			<option value="2">February</option>
  			<option value="3">March</option>
			<option value="4">April</option>
  			<option value="5">May</option>
  			<option value="6">June</option>
			<option value="7">July</option>
  			<option value="8">August</option>
  			<option value="9">September</option>
			<option value="10">October</option>
  			<option value="11">November</option>
  			<option value="12">December</option>
		</select>
		<select id="day" name="day">
			<option value="1">1</option>
			<option value="2">2</option>
			<option value="3">3</option>
			<option value="4">4</option>
			<option value="5">5</option>
			<option value="6">6</option>
			<option value="7">7</option>
			<option value="8">8</option>
			<option value="9">9</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
			<option value="13">13</option>
			<option value="14">14</option>
			<option value="15">15</option>
			<option value="16">16</option>
			<option value="17">17</option>
			<option value="18">18</option>
			<option value="19">19</option>
			<option value="20">20</option>
			<option value="21">21</option>
			<option value="22">22</option>
			<option value="23">23</option>
			<option value="24">24</option>
			<option value="25">25</option>
			<option value="26">26</option>
			<option value="27">27</option>
			<option value="28">28</option>
			<option value="29">29</option>
			<option value="30">30</option>
			<option value="31">31</option>
		</select>
		
		<select id="year" name="year">
			<option value="2010">2010</option>
			<option value="2011">2011</option>
			<option value="2012">2012</option>
			<option value="2013">2013</option>
			<option value="2014">2014</option>
			<option value="2015">2015</option>
			<option value="2016">2016</option>
		</select>
		<br>
		<select id="hour" name="hour">
			<option value="1">1</option>
			<option value="2">2</option>
			<option value="3">3</option>
			<option value="4">4</option>
			<option value="5">5</option>
			<option value="6">6</option>
			<option value="7">7</option>
			<option value="8">8</option>
			<option value="9">9</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
		</select>
		:
		<select name="minute">
			<option value="0">00</option>
			<option value="15">15</option>
			<option value="30">30</option>
			<option value="45">45</option>
		</select>
		<select name="ampm">
			<option value="pm">PM</option>
			<option value="am">AM</option>
		</select>
		<br>
	</span>
	<br><br><br><br><br>
	<span class="goLeft"><span class="heading"> Where? </span></span>
	<span class="goRight">
		Venue<br>
		<input type="text" name="venue" /><br>
		Address or Zip Code<br>
		<input type="text" id="address" /> <br>
		<span class="options">Type anything, then validate with Google Maps</span>
		<input type="button" value="Validate Address" onclick="verifyAddress()" ></input>
		<div id="out"></div>
	</span>
	<br><br><br><br><br><br><br><br><br>
	<span class="goCenter">
		<span class="heading"> Description: </span>
		<span class="heading"> <textarea name="desc" cols="60" rows="4"></textarea></span> <br>
	</span>
	<br><br><br>
	<input type="hidden" name="lat" value="NA" id="lat" />
	<input type="hidden" name="lon" value="NA" id="lon" />
	<input type="hidden" name="callback" value="congrats.jsp" />
	<input type="hidden" name="c_id" value="<%=c_id%>" />
	<input type="submit" disabled="disabled" id="exe" value="Create" />
</span>
</form>
			</div>
		</div>
	</div>
</div>

<%
					} catch (Exception j) {

					}
				}
			} finally {
				query.closeAll();
			}
		}
%>

</body>
</html>
