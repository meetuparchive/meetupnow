<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Date" %>
<%@ page import="meetupnow.RegDev" %>
<%
int maxCount = 10;
int currentCount = 0;

String callback;
if (request.getQueryString() != null) {
	currentCount = Integer.parseInt(request.getParameter("curr"));
}

if (currentCount < maxCount) {
	currentCount++;
	callback = "autoPop.jsp?curr="+currentCount;
} else {
	callback = "";
}

String zip = "06612";
/*
String year;
String month;
String day;
String hour;
String minute;
String ampm;
String tz;
*/
String venue = "Arboretum";
String desc = "Lets Study some Trees!!";
String c_id = "942";
String title = "Tree Studying II";

Date d = new Date();
int offset = (int)Math.random()*48;
d.setHours(d.getHours()+offset);

String query = "?zip="+zip+"&venue="+venue+"&callback="+callback+"&desc="+desc+"&topic="+c_id+"&name="+title+"&mtime="+d.getTime();

String API_URL = "/EventCreate"+query;
APIresponse = sg.submitURL(API_URL);
System.out.println(APIresponse.getBody());

%>
