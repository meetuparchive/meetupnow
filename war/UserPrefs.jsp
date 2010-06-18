<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.UserInfo" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	<%
		String key = "empty";
		String distance = "20";

    		javax.servlet.http.Cookie[] cookies = request.getCookies();

    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		Properties prop = new Properties();
		prop.setProperty("consumer.key","12345");
		prop.setProperty("consumer.secret","67890");
		Scribe scribe = new Scribe(prop);

		PersistenceManager pm = PMF.get().getPersistenceManager();

		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");

		Request APIrequest;
		Response APIresponse;
		String API_URL ="";
	%>

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

										</div><!-- mn_geoListHeader -->
User Preferences - <%=users.get(0).getName()%>
<br><br>
Recieving Notifications from the following groups:
<br>
<%
	String[] groups = profiles.get(0).getGroupArray();
	if (groups.length > 0) {
		String apiParam = groups[0];
		for (int i = 1; i < groups.length; i++) {
			apiParam = apiParam + "," + groups[i];
		}
		Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
		Request APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/ew/containers/?container_id="+apiParam);
		scribe.signRequest(APIrequest,accessToken);
		Response APIresponse = APIrequest.send();
		JSONObject json = new JSONObject();
		JSONArray results;
		try {
			json = new JSONObject(APIresponse.getBody());
			results = json.getJSONArray("results");
			for (int j = 0; j < results.length(); j++) {
%>
-<b><a href="/Group?<%=results.getJSONObject(j).getString("id")%>"><%=results.getJSONObject(j).getString("urlname") %> </a></b>
&nbsp <a href="/setprefs?id=<%=users.get(0).getID()%>&callback=UserPrefs.jsp&group=<%=results.getJSONObject(j).getString("id")%>&action=remove">Remove</a>
<br>
<%
			}
		} catch (JSONException j) {

		}
	}

%>
<br>
Email Address on file:
<br>
<%= profiles.get(0).getEmail() %>
<br><br>
Change your email address?<br>
<form name="email" action="/setprefs">
<input type="text" name="email"></input> Email Address<br>
<br>
What times would you like to recieve notifications? <br>
<input type="checkbox" name="time" value="morning" /> Morning
<input type="checkbox" name="time" value="afternoon" /> Afternoon
<input type="checkbox" name="time" value="night" /> Night
<br>
<br>
<input type="hidden" name="id" value="<%= users.get(0).getID()%>" />
<input type="hidden" name="callback" value="/" />
<input type="submit" value="Change Preferences"></input>
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

<%
					}
				} finally {
					userQuery.closeAll();
				}
			} finally {
				query.closeAll();
			}
		}
%>
<a href="/">Home</a><br>
</div>

</body>
</html>
