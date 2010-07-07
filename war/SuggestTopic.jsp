<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="meetupnow.Topic" %>
<%@ page import="meetupnow.RegDev" %>
<%@ page import="org.json.*" %>
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>
<!DOCTYPE html>
<html>
<head>
	<title>Suggest a Topic</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />

</head>
<body>
<div id="wrap">
	
	<%@ include file="jsp/header.jsp" %>

	<div id="main">

	
		<div id="contentLeft">
			<div id="contentLeftBody">
				<form name="f" action="/" method="get">
					<div id="activityFeed">
						<span class="title">Suggest a Topic</span>
						Name: <br><input type="text" name="title" id="title"></input><br><br>
						Description:<textarea name="desc" id="desc" cols="60" rows="4"></textarea>
						<br><br><input type="submit" value="Submit"></input>
					</div> <!-- end #activityFeed -->
				</form>
			</div> <!-- end #contentLeftBody -->
		</div> <!-- end #contentLeft -->
	</div> <!-- end #main -->
</div> <!-- end #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>
