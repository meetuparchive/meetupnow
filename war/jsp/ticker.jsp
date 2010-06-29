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


<%!
public static String timeBetween(Date d1, Date d2){
	long now = d1.getTime();
	long then = d2.getTime();
	
	long seconds = (now - then)/1000;
	long minutes = seconds/60;
	long hours = minutes/60;
	long days = hours/24;

	if (seconds < 60) {
		if (seconds == 1) {return seconds+" second ago";}
		else {return seconds+" seconds ago";}
	}
	if (minutes < 60) {
		if (minutes == 1) {return minutes+" minute ago";}
		else {return minutes+" minutes ago";}
	}
	if (hours < 24) {
		if (hours == 1) {return hours+" hour ago";}
		else {return hours+" hours ago";}
	}
	if (days == 1) {return days+" day ago";}
	else {return days+" days ago";}

}
%>

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
	<br>
	<%=timeBetween(now,then)%>
</div>
<%
			}
			if (n.getType().equals("event_rsvp")) {
				String evName;
				if (n.getEvConName().equals("")) {
					evName = "An event";
				}
				else {evName = n.getEvConName();}
%>
<div id="tickerContentBox">
	<%=n.getName()%> RSVPed to:
	<br>
	<%=evName%> in Topic <%=n.getContainerName()%>
	<br>
	<%=timeBetween(now,then)%>
</div>
<%
			}
			if (n.getType().equals("event_create")) {
				String evName;
				if (n.getEvConName().equals("")) {
					evName = "An event";
				}
				else {evName = n.getEvConName();}
%>
<div id="tickerContentBox">
	<%=n.getName()%> created an event:
	<br>
	<%=evName%> in Topic <%=n.getContainerName()%>
	<br>
	<%=timeBetween(now,then)%>
</div>
<%
			}
		}
	} catch (Exception e) {};
%>
</marquee>
	</div>
</div>
</div>
</div>
