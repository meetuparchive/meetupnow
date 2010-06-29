<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="meetupnow.NewsItem" %>
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
	
	<%@ include file="jsp/cookie.jsp" %>
	<%@ include file="jsp/declares.jsp" %>
</head>
<body id="meetupNowBody">
	
<%@ include file="jsp/header.jsp" %>

<div id="wrapper">
<div id="wrapperContent">

<div id="ticker">
	<div id="tickerContext">
<marquee direction="left">
<%

PersistenceManager pmr = PMF.get().getPersistenceManager();
List<NewsItem> newsFeed = new ArrayList<NewsItem>();
Query newsQuery = pmr.newQuery(NewsItem.class);
newsQuery.declareParameters("long startdate");
newsQuery.setFilter("timeCreated > startdate");
newsQuery.setOrdering("timeCreated descending");
int MaxMessageLength = 35;
	try {
		newsFeed = (List<NewsItem>) newsQuery.execute(0);
		for (int i = 0; i < newsFeed.size(); i++) {
			NewsItem n = newsFeed.get(i);
			Date now = new Date();
			Date then = new Date(n.getTimeCreated());
			if (n.getType().equals("comment")) {
				String cutMessage = n.getMessage();
				if (cutMessage.length() > MaxMessageLength) {
					cutMessage = cutMessage.substring(0,MaxMessageLength);
					cutMessage = cutMessage.concat("...");
				}

%>
<div id="tickerContentBox">
	<%=n.getName()%> commented on an event:
	<br>
	<%=cutMessage%>
</div>
<%
			}
			//if (n.getType().equals
		}
	} catch (Exception e) {};
%>
</marquee>
	</div>
</div>

	<div id="contentLeft">
		<div id="contentLeftContext">
<span class="title">TEST Header</span>
THIS IS A TEST
		</div>
	</div>
</div>
</div>
</body>
</html>
