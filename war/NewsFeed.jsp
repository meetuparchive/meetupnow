<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="meetupnow.NewsItem" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="java.text.DateFormat" %>

<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	
	<%@ include file="jsp/cookie.jsp" %>

<script type="text/javascript">


$(function() {

var out = $('#output');

var alerts = new Array();
var counter = 0;

<%
List<NewsItem> newsFeed = new ArrayList<NewsItem>();
Query newsQuery = pm.newQuery(NewsItem.class);
newsQuery.declareParameters("long startdate");
newsQuery.setFilter("timeCreated > startdate");
newsQuery.setOrdering("timeCreated descending");
			try {
				newsFeed = (List<NewsItem>) newsQuery.execute(0);
				for (int i = 0; i < newsFeed.size(); i++) {
					NewsItem n = newsFeed.get(i);
				
%>
	
alerts[<%=i%>] = new item("<%=n.getType()%>","<%=n.getName()%>","<%=n.getMessage()%>","<%=n.getEvConName()%>","<%=n.getContainerName()%>","<%=n.getTimeCreated()%>");

<%
				}
			} finally {
				query.closeAll();
			}
%>

window.setInterval(loop, 2000);

function loop() {
	out.empty();
	out.append(alerts[counter].name+": "+alerts[counter].message+"<br>");
	counter = counter + 1;
	if (counter >= alerts.length) {
		counter = 0;
	}
}

});

function item(ty,n,m,e,c,ti) {
	this.type = ty;
	this.name = n;
	this.message = m;
	this.eventName = e;
	this.container = c;
	this.time = ti;
}

</script>


</head>
<body id="meetupNowBody">
	
<%@ include file="jsp/header.jsp" %>

<div id="mn_page">
	<div id="mn_pageBody">
		<div id="mn_context">
			<div id="mn_document">
				<div id="mn_box">
					<div class="d_box">
						<div class="d_boxBody">
							<div class="d_boxHead">
								
							</div>
							<div class="d_boxSection">
								<div id="d_boxContent">
									<div id="mn_geoListContext">
										<div id="mn_geoListHeader">

										</div><!-- mn_geoListHeader -->
<div id="output"> </div>
										<div id="mn_geoListFooter">

										</div><!-- mn_geoListFooter -->
									</div><!-- mn_geoListContext -->
								</div><!-- d_boxContent -->
							</div><!-- d_boxSection -->
						</div><!-- d_boxBody -->
					</div><!-- d_box -->
				</div><!-- mn_box -->
			</div><!-- mn_document -->
		</div><!-- mn_context -->
	</div><!-- mn_pageBody -->
</div><!-- mn_page -->
<%@ include file="jsp/footer.jsp" %>
</body>
</html>
