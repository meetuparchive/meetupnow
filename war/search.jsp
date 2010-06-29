<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="meetupnow.Topic" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>

<%@ page import="org.compass.core.*" %>

<!DOCTYPE html>
<html>
<head>
	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
</head>
<body>
<%@ include file="jsp/header.jsp" %>
<div id="wrapper">
<div id="wrapperContent">
	<div id="contentLeft">
		<div id="contentLeftContext">
			<span class="title">Topic Search</span>
			<form action="/search.jsp" method="get">
				<label for="topicSearchQuery" class="hidden">Enter Topic Search Query</label>
				<input type="text" class="text clearfix" id="topicSearchQuery" name="q" value="">
				<input type="submit" class="submit topicSearchBtn" value="Search Topics">
			</form>

<%
	CompassSearchSession search = PMF.getCompass().openSearchSession();

	String query = request.getParameter("q");
	
if (query != null && query != "") {
	CompassHits hits = null;
	hits = search.queryBuilder().queryString(query).toQuery().setTypes(Topic.class).hits();
	//hits = search.find(query);	
%>

			<span id="tsStatusMsg">Found <%=hits.length() %> hits for query "<% out.write(query); %>"</span>
			

<%
		if (hits.length() > 0) {
%>

			<span class="title">Results</span>
			<div id="activityFeed">
				<div id="activity">
<%
			for (int i = 0; i < hits.length(); i++){
				Topic topic = (Topic) hits.data(i);
				Resource resource = hits.resource(i);
%>

					<div class="commentFeedItem"><a href="/Topic?<%=topic.getId() %>"> <%=topic.getName() %></a></div>
					<br> <%= topic.getDescription() %>

<%
			}
%>

				</div> <!-- end #activity -->
			</div> <!-- end #activityFeed -->

<%
			if (hits.getSuggestedQuery().isSuggested()) {
			    System.out.println("Did You Mean: " + hits.getSuggestedQuery());
			}
		}
	}
%>

		</div> <!-- end #contentLeftContext -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->
</div> <!-- end #wrapper -->

<%@ include file="jsp/footer.jsp" %>
