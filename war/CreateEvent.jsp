<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
	<head>
		<link type="text/css" rel="stylesheet" href="/css/meetupnow.css" />
	</head>

	<body>
		<form name="f" action="/EventCreate" method="get">	
			<p><b><h1>Let's Meetup Now!</h1> Create an Event </b><br><br>
			<input type="text" name="zip" size="6"></input> Enter A Zip Code <br>
			<input type="int" name="month" size="2" value="mm"></input>-
			<input type="int" name="day" size="2" value="dd"></input>-
			<input type="int" name="year" size="4" value="yyyy"></input> Enter A Date <br>
			<input type="int" name="hour" size="2" value="H"></input>:
			<input type="int" name="minute" size="2" value="M"></input> Enter a Time <br>
			<input type="text" name="venue"></input> Where should we meet? <br>
			<input type="hidden" name="callback" value="MUNTest.jsp"></input>
			<input type="submit" value="Create"></input>
			</p>
		</form>
	</body>
</html>
