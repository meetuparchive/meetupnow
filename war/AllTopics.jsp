<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="meetupnow.NewsItem" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="meetupnow.Topic" %>
<%@ page import="org.json.*" %>
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>
<!DOCTYPE html>
<html>
<head>
	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript" src="/js/index.js"></script>
	<script type="text/javascript">





	function loadtopics(){

	<%
		int page2;

		if (request.getQueryString() != null) {
			page2 = Integer.parseInt(request.getParameter("page"));
		}
		else {
			page2 = 1;
		}


		pm = PMF.get().getPersistenceManager();
		
		String TopicList = "container_id=654,713,";
		Query TopicQuery = pm.newQuery(Topic.class);
		TopicQuery.setFilter("id != 0");
		TopicQuery.declareParameters("String reqTokenParam");	//Setup Query

		List<Topic> Topics = new ArrayList<Topic>();
		try {
			Topics = (List<Topic>) pm.detachCopyAll((List<Topic>) TopicQuery.execute(key));
			for (int i = 0; i < Topics.size(); i++){
				TopicList = TopicList + Integer.toString(Topics.get(i).getId()) + ",";
			}
			if (TopicList.charAt(TopicList.length() - 1) == ',')
				TopicList = TopicList.substring(0, TopicList.length() - 1);
		} finally {

		}
		
		

		if (!key.equals("empty")) {
			try {
				users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					API_URL = "http://api.meetup.com/ew/containers.json/?page=10&offset=" + Integer.toString(page2 - 1) + "&link=http://jake-meetup-test.appspot.com";

					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					%>var data = <%=APIresponse.getBody().toString()%><%
				}
			}
			finally {

			}
		}
		else {

			API_URL = "http://api.meetup.com/ew/events?status=upcoming&radius=25.0&order=time&offset=0&format=json&page=200&container_id=654&sig_id=12219924&sig=73487b47859ee335994dac5770ba0d18";
			APIrequest = new Request(Request.Verb.GET, API_URL);
			APIresponse = APIrequest.send();
			%>var data = <%=APIresponse.getBody().toString()%><%
	
		}
		%>
		var out = $('#activityFeed');
		var evArray = new Array();
		$.each(data.results, function(i, ev) {
			
			out.append('<div class="commentFeedItem"><span class="tsItem_title"><a href="/Topic?' + ev.id + '">' + ev.name + '</a></span><span class="tsItem_desc">' + ev.description + '</span><a href="/CreateEvent.jsp?'+ev.id+'">Create an Event</a><div>');
			
		});
		$.each(data.meta, function(i, ev) {

		});
	}
	</script>
</head>
<body onload = "loadtopics()">
<div id="wrap">
	
	<%@ include file="jsp/header.jsp" %>

	<div id="main">
		<div id="contentRight">
			<div id="contentRightBody">
				<div id="mn_geoListContext">
					<div id="mn_geoListHeader">
						<span class="listTitle">Results near [location]</span>
					</div><!-- mn_geoListHeader -->
					<div id="mn_geoListBody">
				
					</div> <!-- end #mn_geoListBody -->
					<div id="mn_geoListFooter">
						<div id="searchResultsNav">
							<span class="showAll"></span>
							<span class="paginationNav"></span>
						</div> <!-- end searchResultsNav -->
					</div><!-- mn_geoListFooter -->
				</div><!-- mn_geoListContext -->
			</div> <!-- end #contentRightBody -->
		</div> <!-- end #contentRight -->
	
		<div id="contentLeft">
			<div id="contentLeftBody">

					<div id="activityFeed">
						<span class="title">Choose a Topic. Create Events.</span>
						<span class="options">Don't see anything you like? <a href="/CreateTopic.jsp">Suggest a new topic!</a></span><br><br>
						<div id = "activity"> </div>
					</div> <!-- end #activityFeed -->
	
			</div> <!-- end #contentLeftBody -->
		</div> <!-- end #contentLeft -->
	</div> <!-- end #main -->
</div> <!-- end #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>