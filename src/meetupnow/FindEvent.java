package meetupnow;

import com.google.appengine.api.datastore.Key;

import java.io.IOException;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.List;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;

import org.scribe.oauth.*;
import org.scribe.http.*;
import org.apache.commons.codec.*;
import org.json.*;

import meetupnow.MeetupUser;
import meetupnow.PMF;


public class FindEvent extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		
		String GEOCODE_URL = "http://maps.google.com/maps/api/geocode/json?address=New+York+City+NY&sensor=true";
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
			resp.sendRedirect("/MeetupNow");
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
				Request APIrequest = new Request(Request.Verb.POST, GEOCODE_URL);
				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				JSONObject json = new JSONObject();
				try {
					json = new JSONObject(APIresponse.getBody());

					//resp.getWriter().println(json.toString());
					//resp.getWriter().println(json.getJSONArray("results").getJSONObject(0).getJSONArray("geometry"));
					String[] names = JSONObject.getNames(json.getJSONArray("results").getJSONObject(0));

				
					String Lng = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");
					String Lat = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat");
					String API_URL = "http://api.meetup.com/ew/events.json/?urlname=muntest&lat=" + Lat + "&lon=" + Lng + "&radius=10";
					resp.getWriter().println(API_URL);
					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					JSONObject meetup_json = new JSONObject();
					try {
						meetup_json = new JSONObject(APIresponse.getBody());
						resp.getWriter().println(meetup_json.toString());
						names = JSONObject.getNames(meetup_json.getJSONArray("results").getJSONObject(0));
						for (int j = 0; j < meetup_json.getJSONArray("results").length(); j++) {
					
							for (int i = 0; i < names.length; i++) {
								String temp = meetup_json.getJSONArray("results").getJSONObject(j).getString(names[i]);
								resp.getWriter().println(temp);
							}	
						}
					} catch (JSONException k) {

					}
					
				} catch (JSONException j) {
		
				}
			}
		}
		finally {
			query.closeAll();
		}

	}
}
