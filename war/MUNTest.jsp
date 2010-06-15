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

<html>
	<head>
		<link type="text/css" rel="stylesheet" href="/css/meetupnow.css" />
	</head>
	<body>

<%
		String key = "empty";
    		Cookie[] cookies = request.getCookies();
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
%>
UPCOMING EVENTS
<br><a href="/oauth?callback=MUNTest.jsp">LOGIN</a>
<%
		}	
		else {

			//FIND USER			

			Properties prop = new Properties();
			prop.setProperty("consumer.key","12345");
			prop.setProperty("consumer.secret","67890");
			Scribe scribe = new Scribe(prop);
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query query = pm.newQuery(MeetupUser.class);
			query.setFilter("accToken == accTokenParam");
			query.declareParameters("String accTokenParam");
			try {
				List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
%>
<p>Welcome, <%=users.get(0).getName()%>!</p>
<p>UPCOMING EVENTS:</p>
<%
					Request APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/events/?urlname=muntest&fields=rsvp_count");
					scribe.signRequest(APIrequest,accessToken);
					Response APIresponse = APIrequest.send();
					JSONObject json = new JSONObject();
					JSONArray results;
					try {
						json = new JSONObject(APIresponse.getBody());
						results = json.getJSONArray("results");
						String[] names = JSONObject.getNames(results.getJSONObject(0));
						for (int j = 0; j < results.length(); j++) {
							JSONObject item = results.getJSONObject(j);
%>

<p><b><%=j %>:</b> <%= (item.getString("city")+", "+item.getString("country")+" "+item.getString("zip")) %> 
<%
						try {
%>
<%=item.getString("venue_name")%>	
<%
						} catch (Exception e) {}
%>			
</p>
<p> &nbsp <%= (item.getString("rsvp_count")+" people are in.") %> 
<%

							if (users.get(0).isAttending(item.getString("id"))) {
%>
&nbsp &nbsp You're In!
<%
							}
							else {
%>
&nbsp &nbsp <a href="<%= "/EventRegister?id="+item.getString("id")+"&callback="+request.getRequestURI() %>">I'm In</a> </p>
<%						
							}
						}
					} catch (JSONException j) {
			
					}
				}
			}
			finally {
				query.closeAll();
			}
		}
%>
	</body>
</html>
