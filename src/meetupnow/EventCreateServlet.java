package meetupnow;

import com.google.appengine.api.datastore.Key;

import java.io.IOException;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.List;
import java.util.Calendar;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;

import org.scribe.oauth.*;
import org.scribe.http.*;
import org.scribe.encoders.URL;
import org.apache.commons.codec.*;
import org.json.*;

import meetupnow.MeetupUser;
import meetupnow.PMF;


public class EventCreateServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String callback = "";
		String zip = "";
		String month = "";
		String day = "";
		String year = "";
		String hour = "";
		String minute = "";
		String venue = "";
		
		if (req.getQueryString() != null) {
			callback = getArg("callback",req.getQueryString());
			zip = getArg("zip",req.getQueryString());
			month = getArg("month",req.getQueryString());
			day = getArg("day",req.getQueryString());
			year = getArg("year",req.getQueryString());
			hour = getArg("hour",req.getQueryString());
			minute = getArg("minute",req.getQueryString());
			venue = req.getParameter("venue");

		}
		String millitime= getMilliTime(year,month,day,hour,minute);

		//String API_URL = "http://api.meetup.com/ew/event/?urlname=muntest&zip="+zip+"&venue_name="+venue+"&time="+millitime;
		String API_URL = "http://api.meetup.com/ew/event/";
		String key = "empty";
    		javax.servlet.http.Cookie[] cookies = req.getCookies();
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
			resp.sendRedirect("/oauth");
		}	
		
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
				Request APIrequest = new Request(Request.Verb.POST, API_URL);
				APIrequest.addBodyParameter("venue_name",venue);
				APIrequest.addBodyParameter("zip",zip);
				APIrequest.addBodyParameter("time",millitime);
				APIrequest.addBodyParameter("urlname","muntest");
				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();

			}
		} 
		finally {
			query.closeAll();
			resp.sendRedirect(callback);
		}

	}

	public static String getMilliTime(String year, String month, String day, String hour, String min) {
		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(year),Integer.parseInt(month) - 1,Integer.parseInt(day) +1 ,Integer.parseInt(hour),Integer.parseInt(min));
		return ""+cal.getTimeInMillis();
	}

	//Parses a given query string and returns the value of reqVar, if it exists
	public static String getArg(String reqVar, String query) {
		StringTokenizer st = new StringTokenizer(query,"&");
		while (st.hasMoreTokens()) {
			String temp = st.nextToken();
			if (temp.startsWith(reqVar)) {
				return temp.substring(reqVar.length() + 1);
			}	
		}
		return "";
	}

}
