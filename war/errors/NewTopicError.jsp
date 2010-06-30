<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="../css/reset.css" type="text/css" />
	<link rel="stylesheet" href="../css/meetupnow.css" type="text/css" />
</head>
<body id="meetupNowBody">
<%@ include file="../jsp/cookie.jsp" %>
<%@ include file="../jsp/declares.jsp" %>
<%@ include file="../jsp/header.jsp" %>
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
										Sorry this topic name has already been taken
										<br><a href="javascript:history.go(-1)"> Go Back </a>

<% 
	if (!c_id.equals("")){
%>									
										<br><a href="/Topic?<%=c_id%>"> Check out Topic Page </a>
<%
	}
%>
				</div>
			</div>
		</div>
	<div>
<%@ include file="../jsp/footer.jsp" %>
</body>
</html>
