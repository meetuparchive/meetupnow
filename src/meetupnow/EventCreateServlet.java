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
		String c_id = "";
		String callback = "";
		String zip = "";
		String month = "";
		String day = "";
		String year = "";
		String hour = "";
		String minute = "";
		String venue = "";
		String desc = "";
		String name = "";
		
		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			zip = req.getParameter("zip");
			month = req.getParameter("month");
			day = req.getParameter("day");
			year = req.getParameter("year");
			hour = req.getParameter("hour");
			minute = req.getParameter("minute");
			venue = req.getParameter("venue");
			desc = req.getParameter("desc");
			c_id = req.getParameter("c_id");
			name = req.getParameter("name");

		}
		String millitime= getMilliTime(year,month,day,hour,minute);

		


		String GEOCODE_URL = "http://maps.google.com/maps/api/geocode/json?address=" + zip + "&sensor=true";
		
		String API_URL = "http://api.meetup.com/ew/event/";
		String key = "empty";
    		javax.servlet.http.Cookie[] cookies = req.getCookies();

		Request GoogleAPIrequest = new Request(Request.Verb.POST, GEOCODE_URL);
		Response GoogleAPIresponse = GoogleAPIrequest.send();
		String Lat = "0";
		String Lng = "0";
		String City = "";
		String State = "";
		String Country = "";

		try{
			JSONObject json = new JSONObject(GoogleAPIresponse.getBody());

			String[] names = JSONObject.getNames(json.getJSONArray("results").getJSONObject(0));

			Lng = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");
			Lat = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat");


			JSONArray Location = json.getJSONArray("results").getJSONObject(0).getJSONArray("address_components");
			City = Location.getJSONObject(0).getString("short_name");
			State = Location.getJSONObject(2).getString("short_name");
			Country = Location.getJSONObject(3).getString("short_name");
			System.out.println("City: " + City + " State: " + State + " Country: " + Country);


			for (int i = 0; i< Location.length(); i++){
				System.out.println(i + ": " + Location.getJSONObject(i).getString("short_name"));
			}


		}
		catch(JSONException k){
			
		}



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
				//APIrequest.addBodyParameter("city",City);
				//APIrequest.addBodyParameter("state",State);
				//APIrequest.addBodyParameter("country", Country);
				APIrequest.addBodyParameter("zip", zip);
				APIrequest.addBodyParameter("time",millitime);
				APIrequest.addBodyParameter("container_id",c_id);
				APIrequest.addBodyParameter("description",desc);
				APIrequest.addBodyParameter("title",name);
				APIrequest.addBodyParameter("fields","title");
				

				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				System.out.println(APIresponse.getBody());

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


}
