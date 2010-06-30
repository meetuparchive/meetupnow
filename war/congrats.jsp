<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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


<div id="wrapper">
	<div id="wrapperContent">
		<div id="contentLeft">
			<div id="contentLeftContext">

<% if (request.getParameter("id") != null && request.getParameter("id") != ""){%>
	<span class="title">CONGRATUMULATIONS</span>
	<span class="heading">
	<br>
	You sucessfully created a Meetup Now event. Would you like to share it with your friends?
	<br>
	FACEBOOK
	<br>
	<a name="fb_share" type="button" title="test" share_url="http://jake-meetup-test.appspot.com/Event?id=<%=request.getParameter("id")%>" href="http://www.facebook.com/sharer.php">Share</a><script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" type="text/javascript"></script>
	<br>
	TWITTER
	<br>
	<a href="http://twitter.com/home?status=Just posted an event on Meetup Now: http://jake-meetup-test.appspot.com/Event?id=<%=request.getParameter("id")%>" title="Click to send this page to Twitter!" target="_blank">Share on Twitter </a>
	<br>
	EMAIL
	<br>
	TEXT
	<br>
	<br>
	<a href="/Event?<%=request.getParameter("id")%>"> Go to my event page</a>
	</span>

<% } else { %>

	ERROR!!!!!!<br>
	<a href="javascript: history.go(-1)">Go Back</a>
<%}%>
				</div>
			</div>
		</div>
	<div>
<%@ include file="jsp/footer.jsp" %>
</body>
</html>
