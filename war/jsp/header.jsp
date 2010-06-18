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





<div id="mew_header">
	<div id="mew_headerBody">
		<div id="mew_logo">
			<a href="/">
				<img src="../images/mnlogo_sm.png" alt="Meetup" style="width: auto !important; height: auto !important">
			</a>
		</div><!-- mew_logo -->
		<div id="mew_userNav">
<%
		
		if (key.equals("empty")) {
%>
<a href="/oauth">Log In</a>
<%
		} else {
			//FIND USER			

		
			try {
				users = (List<MeetupUser>) query.execute(key);
					
%>
<p><%=users.get(0).getName()%>
<a href ="/logout?callback=">LOGOUT</a></p>
<%
			} finally {
				query.closeAll();
			}
		}
%>
</div>
	</div><!-- mew_headerBody -->
</div><!-- mew_header -->

