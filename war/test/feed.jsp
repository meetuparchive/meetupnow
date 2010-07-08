<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="meetupnow.NewsItem" %>
<%@ page import="meetupnow.PMF" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Feed</title>
	<link rel="stylesheet" href="feed.css" type="text/css" />

	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
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
<%
int numBoxes = 3;
%>
<script type="text/javascript">

var alerts = new Array();

$(function() {
var count = 0;
  $("button").click(function () {
	var n = count + <%=numBoxes%>;
	var one = count + 1;
	var two = count + 2;
	$("div:."+count+",."+one+",."+two).fadeTo('slow', 0.0, function () {
				addBox(n);
	$("div:."+count+",."+one+",."+two).slideUp(function () {


	});
	count++;
	});

  });

var counter = 0;

<%
PersistenceManager pm = PMF.get().getPersistenceManager();
List<NewsItem> newsFeed = new ArrayList<NewsItem>();
Query newsQuery = pm.newQuery(NewsItem.class);
newsQuery.declareParameters("long startdate");
newsQuery.setFilter("timeCreated > startdate");
newsQuery.setOrdering("timeCreated descending");
			try {
				newsFeed = (List<NewsItem>) newsQuery.execute(0);
				for (int i = 0; i < newsFeed.size(); i++) {
					NewsItem n = newsFeed.get(i);
 					Date now = new Date();
					Date then = new Date(n.getTimeCreated());
				
%>
	
alerts[<%=i%>] = new item("<%=n.getType()%>","<%=n.getName()%>","<%=n.getMessage()%>","<%=n.getEvConName()%>","<%=n.getContainerName()%>","<%=timeBetween(now,then)%>","<%=n.getLink()%>");

<%
			
				}
for (int i=0; i<numBoxes; i++) {
%>
	addBox(<%=i%>);
<%
}
			} finally {
				newsQuery.closeAll();
			}
%>
//var interval = window.setInterval(loop, 4);
function loop() {
	var n = count + <%=numBoxes%>
	$("div:."+count).fadeOut(function () {
		addBox(n);

	});
	count++;
var randomnumber = Math.floor(Math.random()*15000)
if (randomnumber < 5000) {randomnumber = 5000};
window.clearInterval(interval);
interval = window.setInterval(loop, randomnumber);
}
});

function item(ty,n,m,e,c,ti,l) {
	this.type = ty;
	this.name = n;
	this.message = m;
	this.eventName = e;
	this.container = c;
	this.time = ti;
	this.link = l;
}
function formatAlert(alert) {
	var evName;
	var contain;
	if (alert.type == "comment") {
		if (alert.eventName == "null") { evName = "on an event"; }
		else {evName = "on event " + alert.eventName;}
		return "<i>"+alert.name+"</i> commented <a href=\""+alert.link+"\"><b>"+evName+"</b></a>: <b>"+ alert.message+"</b> <i> ~ "+alert.time+"</i>";
	}
	if (alert.type == "event_create") {
		if (alert.container == "null") {contain = "";}
		else { contain = "in topic "+alert.container;}
		return "<i>"+alert.name+"</i> created a new event<br> "+contain+": <a href=\""+alert.link+"\"><b>"+alert.eventName+"</b></a><i><br> ~ "+alert.time+"</i>";
	}
	if (alert.type == "event_rsvp") {
		if (alert.eventName == "null") {evName = "an event";}
		else {evName = alert.eventName;}
		if (alert.container == "null") {contain = "";}
		else {contain = " in topic "+alert.container;}
		return "<i>"+alert.name+"</i> will be attending<br><a href=\""+alert.link+"\"><b>"+evName+"</b></a><br>"+contain+" <i><br> ~ "+alert.time +"</i>";
	}

}

function addBox(i) {
	$('#out').append("<div class=\""+i+"\"><div class=\"tickerContentBox\">"+formatAlert(alerts[i])+"</div></div>");
}


</script>
</head>

<body>
	<div id="ticker">
		<div class="tickerContext" id="out">
			
		</div>
	</div>
<br><br><br>
<button>
Click Me
</button>



</body>
</html>
