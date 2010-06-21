<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%@ page import="org.json.*" %>
<%@ page import="java.util.Date" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meetup Now</title>
	<link rel="stylesheet" href="css/reset.css" type="text/css" />
	<link rel="stylesheet" href="css/meetupnow.css" type="text/css" />
	
    <script language="javascript" type="text/javascript" src="../js/flot/jquery.js"></script>
    <script language="javascript" type="text/javascript" src="../js/flot/jquery.flot.js"></script>

<%!
public double distance(double lat1, double lon1, double lat2, double lon2) {
	double R = 6371; // km
	double dLat = (lat2-lat1)*(Math.PI / 180);
	double dLon = (lon2-lon1)*(Math.PI / 180); 
	double a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon/2) * Math.sin(dLon/2); 
	double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	double d = R * c * 0.621371192;
	return d;
}  
%>

<%!
public static long daysBetween(Date d1, Date d2){
    long ONE_HOUR = 60 * 60 * 1000L;
    return ( (d2.getTime() - d1.getTime() + ONE_HOUR) / 
                  (ONE_HOUR * 24));
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
<%
		if (!key.equals("empty")) {
			try {
				users = (List<MeetupUser>) query.execute(key);
				if (users.iterator().hasNext()) {
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					API_URL = "http://api.meetup.com/ew/events/?status=upcoming&urlname=muntest2&lat=" + users.get(0).getLat() + "&lon=" + users.get(0).getLon() + "&radius=50";
					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					JSONObject json = new JSONObject();
					JSONArray results;
					try {
						json = new JSONObject(APIresponse.getBody());
						results = json.getJSONArray("results");
						String graphString = "";
						for (int i = 0; i < results.length(); i++) {
							JSONObject item = results.getJSONObject(i);
							double dist = distance(Double.parseDouble(users.get(0).getLat()),Double.parseDouble(users.get(0).getLon()),Double.parseDouble(item.getString("lat")),Double.parseDouble(item.getString("lon")));

							Date d1 = new Date();
							Date d2 = new Date(Long.parseLong(item.getString("time")));
							graphString = graphString.concat("["+daysBetween(d1,d2)+","+dist+"],");
						}
						

%>






TEST GRAPH
<script id="source" language="javascript" type="text/javascript">
$(function () {
    var d = [<%=graphString %>];

    var plot = $.plot($("#placeholder"),
           [ { data: d, label: "events"} ], {
               series: {
                   points: { show: true }
               },
               grid: { hoverable: true, clickable: true },
                yaxis: { min: 0},
		xaxis: {min:0},

             });

    function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    }

    var previousPoint = null;
    $("#placeholder").bind("plothover", function (event, pos, item) {
            if (item) {
                if (previousPoint != item.datapoint) {
                    previousPoint = item.datapoint;
                    
                    $("#tooltip").remove();
                    var x = item.datapoint[0].toFixed(2),
                        y = item.datapoint[1].toFixed(2);
                    
                    showTooltip(item.pageX, item.pageY,"TEST");
                }
            }
            else {
                $("#tooltip").remove();
                previousPoint = null;            
            }
    });

    $("#placeholder").bind("plotclick", function (event, pos, item) {
        if (item) {
            $("#clickdata").text("event is "+pos.x.toFixed(1)+" days and "+pos.y.toFixed(1)+" miles away!");
        }
    });
});
</script>



<div id="placeholder" style="width:600px;height:300px;"></div>

 <p id="hoverdata"><span id="clickdata"></span></p>

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
					}  catch (JSONException j) {
		
					}
				}
			}
			finally {

			}
		}
%>

<%@ include file="jsp/footer.jsp" %>
</body>
</html>
