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

<%@ page import="meetupnow.MUCookie" %>

<div id="mn_superHeader">
	<div id="mn_superHeaderBody">
		<div id="mn_superHeader_logo">
			<a href="/">
				<img src="../images/mnlogo_sm_white.png" alt="MeetupNow" style="width: auto !important; height: auto !important">
			</a>
		</div><!-- mew_logo -->
		<div id="mn_superHeader_usernav">
			<ul>
<%

		PersistenceManager p = PMF.get().getPersistenceManager();
		Query q = p.newQuery(MeetupUser.class);
		q.setFilter("accToken == accTokenParam");
		q.declareParameters("String accTokenParam");
		String k = meetupnow.MUCookie.getCookie(request.getCookies());
		if (k.equals("empty")) {
%>
				<li><a href="/oauth">Log In</a></li>
				<li><a href="#modal_register" name="modalregister" id="#modal_register">Register</a></li>
<%
		} else {
			//FIND USER			

		
			try {
				List<MeetupUser> use = (List<MeetupUser>) q.execute(k);
					
%>
<li><%=use.get(0).getName()%></li>

<li><a href ="">My Events</a></li>

<li><a href ="/UserPrefs.jsp">Preferences</a> </li>

<li><a href ="/logout?callback=">Log Out</a></li>
<%
			} finally {
				q.closeAll();
			}
		}
%>
</ul>
</div>
	</div><!-- mew_headerBody -->
</div><!-- mew_header -->

