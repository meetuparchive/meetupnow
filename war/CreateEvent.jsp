<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
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
%>

<div id="wrapper">
	<div id="wrapperContent">
		<div id="contentLeft">
			<div id="contentLeftContext">
<span class="title">Create An Event - Let's Meetup Now!</span><br>
<form name="f" action="/EventCreate" method="get">


	<span class="goLeft"><span class="heading"> Topic: </span></span>
	<span class="goRight"> TOPIC WILL GO HERE</span>
	<br><br><br><br>
	<span class="goLeft"><span class="heading"> Title: </span></span>
	<span class="goRight"><input type="text" name="name" /></span>
	<br><br><br><br><br>
	<span class="goLeft"><span class="heading"> When? </span></span>
	<span class="goRight">
		<input type="int" name="month" size="2" value="mm" />-
		<input type="int" name="day" size="2" value="dd" />-
		<input type="int" name="year" size="4" value="yyyy" /> Date <br>
		<input type="int" name="hour" size="2" value="H" />:
		<input type="int" name="minute" size="2" value="M" /> Time <br>
	</span>
	<br><br><br><br><br>
	<span class="goLeft"><span class="heading"> Where? </span></span>
	<span class="goRight">
		<input type="text" name="venue" /> Venue <br>
		<input type="text" name="zip" size="6" /> Zip Code <br>
	</span>
	<br><br><br><br><br>
	<span class="goLeft"><span class="heading"> Description: </span></span>
	<span class="goRight">
		<textarea name="desc" cols="40" rows="6"></textarea> <br>
	</span>
	<br><br><br><br><br><br><br><br><br><br>
	<input type="hidden" name="callback" value="congrats.jsp" />
	<input type="hidden" name="c_id" value="<%=c_id%>" />
	<input type="submit" value="Create" />
</span>
</form>

			</div>
		</div>
	</div>
</div>

</body>
</html>
