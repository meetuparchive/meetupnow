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

<div id="header">

		<div id="header_logo">
			<a href="/">
				<ul><li><a href="/">Home</a></li></ul>
			</a>
		</div><!-- mn_superHeader_logo -->
		<div id="header_usernav">
			<ul>
<%

		PersistenceManager p = PMF.get().getPersistenceManager();
		Query q = p.newQuery(MeetupUser.class);
		q.setFilter("accToken == accTokenParam");
		q.declareParameters("String accTokenParam");
		String k = meetupnow.MUCookie.getCookie(request.getCookies());
		if (k.equals("empty")) {
%>
				<li><a href="#modal_login" name="modal">Log In</a></li>
				<li><a href="#modal_register" name="modal">Register</a></li>
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
		</div> <!-- end #header_usernav -->

</div><!-- end #header -->

<script type="text/javascript" charset="utf-8">
	// Modal Registration Popup
	$(document).ready(function() {

		// Add necessary DIVs
		$('body').append('<div id="modal_register" class="modalRounded"><iframe src="http://www.meetup.com/register/?set_mobile=on" width="400px" height="550px" align="top" scrolling="no" frameborder="0" border="0" cellspacing="0"></iframe></div><div id="mask"></div>');
		$('body').append('<div id="modal_login" class="modalRounded"><iframe src="/oauth?callback=success.jsp" width="400px" height="550px" align="top" scrolling="no" frameborder="0" border="0" cellspacing="0" class="modalRounded"></iframe></div><div id="mask"></div>');

		// Global var to store activate modal div
		var gId;

		// Select Register link
		$('a[name=modal]').click(function(e) {

			// Cancel default link behavior
			e.preventDefault();
			// Get the anchor tag
			var id = $(this).attr('href');

			// Get the screen height and width
			var maskHeight = $(document).height();
			var maskWidth = $(window).width();

			// Set height and width for mask to fill up the whole screen
			$('#mask').css({'width':maskWidth, 'height':maskHeight});

			// Transition effect
			$('#mask').fadeIn(500);
			//$('#mask').fadeTo("slow",0.8);

			// Get the window height and width
			var winH = $(window).height();
			var winW = $(window).width();

			// Set the popup window to center
			$(id).css('top', winH/2-$(id).height()/2);
			$(id).css('left',winW/2-$(id).width()/2);

			// Transition effect
			$(id).fadeIn(1000);

			// Pass to global variable
			gId = id;
		});

		// If mask is clicked, hide mask and activated modal dialogue
		$('#mask').click(function() {
			$(this).hide();
			$(gId).hide();
		})
	});
</script>
