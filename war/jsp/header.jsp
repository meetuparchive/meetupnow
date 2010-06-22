<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="java.io.IOException" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="javax.servlet.http.Cookie" %>





<div id="mn_superHeader">
	<div id="mn_superHeaderBody">
		<div id="mn_superHeader_logo">
			<a href="#">
				<img src="../images/mnlogo_sm_white.png" alt="MeetupNow" style="width: auto !important; height: auto !important">
			</a>
		</div><!-- mew_logo -->
		<div id="mn_superHeader_usernav">
			<ul>
<%
		
		if (key.equals("empty")) {
%>
<li><a href="/oauth">Log In</a></li>
<%
		} else {
			//FIND USER			

		
			try {
				users = (List<MeetupUser>) query.execute(key);
					
%>
<li><%=users.get(0).getName()%></li>

<li><a href ="">My Events</a></li>

<li><a href ="/UserPrefs.jsp">Preferences</a> </li>

<li><a href ="/logout?callback=">Log Out</a></li>
<%
			} finally {
				query.closeAll();
			}
		}
%>
</ul>
</div>
	</div><!-- mew_headerBody -->
</div><!-- mew_header -->

