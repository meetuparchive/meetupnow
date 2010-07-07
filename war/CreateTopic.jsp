<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
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
</head>
<body>
<%@ include file="jsp/cookie.jsp" %>
<%@ include file="jsp/declares.jsp" %>

<%

		String c_id = "";		
		if (request.getQueryString() != null) {
			c_id = request.getQueryString();
		}
%>

<div id="wrap">
	
<%@ include file="jsp/header.jsp" %>

<div id="main">
	<div id="contentTop">
		<div id="contentTopBody">
			<span class="title">Suggest a New Topic</span>
			<form id="suggestTopic" name="f" action="/TopicCreate" method="get">
				<fieldset>
					<legend><span class="hidden">Suggest a Topic</legend>
						<ul>
							<li>
								<label for="suggestTopicName">New Topic Name</label>
								<input type="test" name="suggestTopicName" id="suggestTopicName">
							</li>
							<li>
								<label for="suggestTopicDesc">Topic Description</label>
								<textarea name="suggestTopicDesc" id="suggestTopicDesc"></textarea>
							</li>
							<li>
								<label for="suggestTopicKeywords">Keywords (used for search)</label>
								<textarea name="suggestTopicKeywords" id="suggestTopicKeywords"></textarea>
							</li>
						</ul>
							
								<input type="hidden" name="callback" value="Topic?<%=c_id%>" />
								<input type="hidden" name="c_id" value="<%=c_id%>" />
								<input type="submit" value="Suggest" class="createBtn"/>
				</fieldset>
			</form>
		
		</div><!-- end #contentTopBody -->
	</div><!-- end #contentTop -->
</div><!-- #main -->
</div><!-- #wrap -->

<%@ include file="jsp/footer.jsp" %>

</body>
</html>
