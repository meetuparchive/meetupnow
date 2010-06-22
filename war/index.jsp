<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>

<%@ page import="java.io.IOException" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="meetupnow.OAuthServlet" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript" src="/js/index.js"></script>
	<script type="text/javascript">

		
		function loadEvents(){
		<%@ include file="jsp/cookie.jsp" %>

		<%

		

		if (!key.equals("empty")) {
			try {
				users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					API_URL = "http://api.meetup.com/ew/events/?status=upcoming&urlname=muntest&lat=" + users.get(0).getLat() + "&lon=" + users.get(0).getLon() + "&radius=" + distance;
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
			use_everywhere(data);
		}

	</script>
</head>
<body id="meetupNowBody" onload="loadEvents()">



	
<%@ include file="jsp/header.jsp" %>

<div id="mn_page">
	<div id="mn_pageBody">
		<div id="mn_context">
			<div id="mn_document">
				<div id="mn_box">
					<div class="d_box">
						<div class="d_boxBody">
							<div class="d_boxHead">
								<img src="images/mn_banner2.png" alt="Meetup Now">
								<div id="TICKER" style="overflow:hidden; width:936px" onmouseover="TICKER_PAUSED=true" onmouseout="TICKER_PAUSED=false">
								  	<span style="font-family:Arial; font-size:12px; color:#444444" id="TICKER_BODY" width="100%">
											<span style="background-color:#7FB51A;"> &nbsp; &nbsp; <font color="#FFFFFF"> <b>Scrolling News Ticker</b></font>&nbsp; &nbsp; </span> &nbsp; <b>You can add this ticker in your own web pages.</b>&nbsp; 
											<span style="background-color:#FFAA00;"> &nbsp; &nbsp; <font color="#FFFFFF"> <b>Free</b></font>&nbsp; &nbsp; </span> &nbsp; <b>You can add it for free, in exchange of a link to this page.</b>&nbsp; 
											<span style="background-color:#0088FF;"> &nbsp; &nbsp; <b><a href="http://www.mioplanet.com/rsc/develop_ticker.htm"><font color="#FFFFFF"> Desktop News Ticker</font></a></b>&nbsp; &nbsp; </span>&nbsp;
											<b>And why not to offer to your visitors your own <a href="http://www.mioplanet.com/rsc/develop_ticker.htm"><u>Desktop News Ticker</u></a>? This is the perfect tool to attract and keep visitors... <a href="http://www.mioplanet.com/solutions/desktopticker/index.htm"><u>More info</u></a></b>&nbsp; 
										</span>
								</div>
								<script type="text/javascript" src="js/webticker_lib.js" language="javascript"></script>
							</div>
							<div class="d_boxSection">
								<div id="d_boxContent">
									
									<div id="d_boxContentRight">
										<div id="mn_description">
											<span class="subtitle"></span>
											<span class="subtitle">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua?</span>
											<span class="title">Lorem ipsum!</span>
											<span class="button_start">Get Started!</span>
										</div><!-- mn_description -->
										<div id="mn_eventDescription">
												<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
										</div><!-- mn_eventDescription -->

									</div><!-- d_boxContentRight -->
									
									<div id="d_boxContentLeft">
										<div class="map_context">
											<span class="map_title title">Happening NOW near you...</span>
											<div id="map_canvasContainer">
												<div id="map_canvas">
										
												</div><!-- map_canvas -->
											</div><!-- map_canvasContainer -->
										</div><!-- map_context -->
										<div id="mn_geoListContext">
											<div id="mn_geoListHeader">
												<span>Today in Sports<span>
											</div><!-- mn_geoListHeader -->
											
											<div id="mn_geoListFooter">
										
											</div><!-- mn_geoListFooter -->
										</div><!-- mn_geoListContext -->
									</div><!-- d_boxContentLeft -->
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
