<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
	<head>
		<link type="text/css" rel="stylesheet" href="/css/meetupnow.css" />
	</head>

	<body>
		<form name="f" action="/FindEvent" method="get">	
			<p><b><h1>Let's Meetup Now!</h1> Find An Event </b><br><br>
			<input type="text" name="zip" size="6"></input> Enter A Zip Code <br>
			<input type="text" name="dist"></input> How far can you go? <br>
			<input type="hidden" name="callback" value="MUNTest.jsp"></input>
			<input type="submit" value="Create"></input>
			</p>
		</form>
	</body>
</html>
