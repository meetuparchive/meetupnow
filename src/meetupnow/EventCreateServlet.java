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
import meetupnow.NewsItem;


public class EventCreateServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String c_id = "";
		String callback = "";
		String lat = "";
		String lon = "";
		String ad = "";
		String city = "";
		String state = "";
		String country = "";
		String month = "";
		String day = "";
		String year = "";
		String hour = "";
		String minute = "";
		String ampm = "";
		String venue = "";
		String desc = "";
		String name = "";
		String zip = "";		

		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			month = req.getParameter("month");
			day = req.getParameter("day");
			year = req.getParameter("year");
			hour = req.getParameter("hour");
			minute = req.getParameter("minute");
			venue = req.getParameter("venue");
			desc = req.getParameter("desc");
			c_id = req.getParameter("c_id");
			name = req.getParameter("name");
			ampm = req.getParameter("ampm");
			lat = req.getParameter("lat");
			lon = req.getParameter("lon");
			ad = req.getParameter("ad");
			city = req.getParameter("city");
			state = req.getParameter("state");
			country = req.getParameter("country");
			zip = req.getParameter("zip");

		}
		String millitime= getMilliTime(year,month,day,hour,minute,ampm);
		String rsvpID = "";
		String containerName = "";
		

		
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
				if ((!ad.equals(""))&&(!city.equals("NA"))&&(!country.equals("NA"))) {
					APIrequest.addBodyParameter("city", city);
					APIrequest.addBodyParameter("country", country);
					System.out.println(city+" "+country+" "+state+" "+ad);
					if (country.equals("United States")){APIrequest.addBodyParameter("state", state);}
					APIrequest.addBodyParameter("address1", ad);
				} else if (zip != null) {
					APIrequest.addBodyParameter("zip", zip);

				} else {
					APIrequest.addBodyParameter("lat", lat);
					APIrequest.addBodyParameter("lon", lon);
				}
				APIrequest.addBodyParameter("time",millitime);
				APIrequest.addBodyParameter("container_id",c_id);
				APIrequest.addBodyParameter("description",desc);
				APIrequest.addBodyParameter("title",name);
				APIrequest.addBodyParameter("fields","title");
				APIrequest.addBodyParameter("organize","true");
				

				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				
				JSONObject json = new JSONObject(APIresponse.getBody());
				rsvpID = json.getString("id");
				callback = callback.concat("?id="+rsvpID);
				containerName = json.getJSONObject("container").getString("name");

				//Create notification
				NewsItem notify = new NewsItem();
				notify.setType("event_create");
				notify.setName(users.get(0).getName());
				if (desc.length() > 100) {
					notify.setMessage(desc.substring(0,97).concat("..."));
				}
				else {
					notify.setMessage(desc);
				}
				notify.setLink("/Event?"+rsvpID);
				notify.setEvConName(name);
				notify.setContainerName(containerName);

				try {
					pm.makePersistent(notify);
				} finally {
					
				}
			}
		} catch (JSONException j){
			
		}
		finally {
			query.closeAll();
			pm.close();
			if (rsvpID.equals("")) {
				resp.sendRedirect(callback);
			}	
			else {
				resp.sendRedirect("/EventRegister?id="+rsvpID+"&callback="+callback);
			}
		}

	}

	public static String getMilliTime(String year, String month, String day, String hour, String min, String ampm) {
		int dateHour;
		if (ampm.equals("am")) {
			if (hour.equals("12")) {
				dateHour = 0;
			} else {
				dateHour = Integer.parseInt(hour);
			}
		} else {
			if (hour.equals("12")) {
				dateHour = 12;
			} else {
				dateHour = Integer.parseInt(hour)+12;
			}
		}
		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(year),Integer.parseInt(month) - 1,Integer.parseInt(day) ,dateHour,Integer.parseInt(min));
		return ""+cal.getTimeInMillis();
	}


}
