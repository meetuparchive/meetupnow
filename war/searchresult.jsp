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
<%@ page import="meetupnow.RegDev" %>

<%@ page import="java.util.Date" %>

<%@ page import="org.compass.core.*" %>

<!DOCTYPE html>
<html>
<head>
	<title>MeetupNOW</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
</head>
<body>
		<%@ include file="jsp/cookie.jsp" %>
		<%@ include file="jsp/declares.jsp" %>

		<%@ page import="meetupnow.Topic" %>
<%@ include file="jsp/header.jsp" %>
<div id="wrapper">
<div id="wrapperContent">
	<div id="contentLeft">
		<div id="contentLeftContext">


<%
	CompassSearchSession search = PMF.getCompass().openSearchSession();

	String querystring = request.getParameter("query");
	String locationquery = request.getParameter("location");
		String containers = "&container_id=";
if (locationquery != "" && locationquery != null){	

	if (querystring != null && querystring != "") {
		RegDev sg = new RegDev();
		CompassHits hits = null;
		hits = search.queryBuilder().queryString(querystring).toQuery().setTypes(Topic.class).hits();
		String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?address=" + locationquery +"&sensor=true";
		APIresponse = sg.submitURL(GEOCODE_API_URL);
		JSONObject json = new JSONObject(APIresponse.getBody());


		API_URL = "http://api.meetup.com/ew/events/?radius=10&lat=" + json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat") + "&lon=" + json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");
		System.out.println(API_URL); 
%>

			<span id="tsStatusMsg">Found <%=hits.length() %> hits for query "<% out.write(querystring); %>"</span>
			

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
				if (i < hits.length() - 1){			
					containers = containers + Integer.toString(topic.getId()) + ",";

				}else{
					containers = containers + Integer.toString(topic.getId());

				}
			}

			if (hits.getSuggestedQuery().isSuggested()) {
			    System.out.println("Did You Mean: " + hits.getSuggestedQuery());
			}
			API_URL = API_URL + containers;
	APIResponse = Sg.submitURL(API_URL);
	System.out.println(APIResponse.getBody());
		}
	} else {

	}
}
%>
				</div> <!-- end #activity -->
			</div> <!-- end #activityFeed -->
		</div> <!-- end #contentLeftContext -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->
</div> <!-- end #wrapper -->

<%@ include file="jsp/footer.jsp" %>
