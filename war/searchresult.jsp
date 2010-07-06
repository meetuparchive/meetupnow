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
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
		<%@ include file="jsp/cookie.jsp" %>
		<%@ include file="jsp/declares.jsp" %>

		<%@ page import="meetupnow.Topic" %>
	<script>





<%
	CompassSearchSession search = PMF.getCompass().openSearchSession();
	RegDev sg = new RegDev();
	String querystring = request.getParameter("query");
	String locationquery = request.getParameter("location");
	String containers = "&container_id=";
	JSONObject json;


if (querystring != null && locationquery != null){

	if (!locationquery.equals("")){	

		if (!querystring.equals("")) {
	System.out.println(!querystring.equals("") + " " + !locationquery.equals(""));
			CompassHits hits = null;
			hits = search.queryBuilder().queryString(querystring).toQuery().setTypes(Topic.class).hits();
			String GEOCODE_API_URL = "http://maps.google.com/maps/api/geocode/json?address=" + locationquery +"&sensor=true";
			APIresponse = sg.submitUnsignedURL(GEOCODE_API_URL);
			json = new JSONObject(APIresponse.getBody());


			API_URL = "http://api.meetup.com/ew/events/?link=http://jake-meetup-test.appspot.com/&radius=10&lat=" + json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat") + "&lon=" + json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");


			if (hits.length() > 0) {

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
				System.out.println(API_URL);

			}


			APIresponse = sg.submitURL(API_URL);
			json = new JSONObject(APIresponse.getBody());
	%> var data = <%=json.toString() %> <%


		} else {
			%> var data = null <%
		}

	} else {
		%> var data = null <%
	}
} else {
	%> var data = null <%
}
%>

	if (data != null){
		alert(data);
		$.each(data.results, function(i, ev) {
			alert(ev.title);
			$('#activity').append('<div class="commentFeedItem"><span class="tsItem_title"><a href="/Topic?' + ev. id + '">' + ev.title + '</a></span></div>');
		});

	}


	</script>
</head>
<body>
<%@ include file="jsp/header.jsp" %>
<div id="wrapper">
<div id="wrapperContent">
	<div id="contentLeft">
		<div id="contentLeftContext">
			<span class="title">Results</span>
			<div id="activityFeed">
				<div id="activity">
				
				</div> <!-- end #activity -->
			</div> <!-- end #activityFeed -->
		</div> <!-- end #contentLeftContext -->
	</div> <!-- end #contentLeft -->
</div> <!-- end #wrapperContent -->
</div> <!-- end #wrapper -->

<%@ include file="jsp/footer.jsp" %>
