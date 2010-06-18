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
<%

		String c_id = "";		
		if (request.getQueryString() != null) {
			c_id = request.getQueryString();
		}
%>
		<%@ include file="jsp/cookie.jsp" %>

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

							<b>Let's Meetup Now!<br> Create an Event </b><br><br>

										</div><!-- mn_geoListHeader -->
		<form name="f" action="/EventCreate" method="get">	
			<input type="text" name="zip" size="6"></input> Enter A Zip Code <br>
			<input type="int" name="month" size="2" value="mm"></input>-
			<input type="int" name="day" size="2" value="dd"></input>-
			<input type="int" name="year" size="4" value="yyyy"></input> Enter A Date <br>
			<input type="int" name="hour" size="2" value="H"></input>:
			<input type="int" name="minute" size="2" value="M"></input> Enter a Time <br>
			<input type="text" name="venue"></input> Where should we meet? <br>
			<input type="text" name="desc"></input> What's this meetup all about? <br>
			<input type="hidden" name="callback" value="Group?<%=c_id%>"></input>
			<input type="hidden" name="c_id" value="<%=c_id%>"></input>
			<input type="submit" value="Create"></input>
		</form>


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
