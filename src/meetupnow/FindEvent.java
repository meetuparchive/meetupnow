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
import meetupnow.Message;


public class FindEvent extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		

		String key = "empty";
		String callback = "";
		String zip = "";
		String distance = "";

    		javax.servlet.http.Cookie[] cookies = req.getCookies();
		resp.setContentType("text/html");
		
		if (req.getQueryString() != null) {
			callback = getArg("callback",req.getQueryString());
			zip = getArg("zip",req.getQueryString());
			distance = getArg("dist",req.getQueryString());
		}
		String GEOCODE_URL = "http://maps.google.com/maps/api/geocode/json?address=" + zip + "&sensor=true";

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

		JSONObject meetup_json = new JSONObject();

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

					String[] names = JSONObject.getNames(json.getJSONArray("results").getJSONObject(0));

				
					String Lng = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lng");
					String Lat = json.getJSONArray("results").getJSONObject(0).getJSONObject("geometry").getJSONObject("location").getString("lat");
					String API_URL = "http://api.meetup.com/ew/events.json/?urlname=muntest&lat=" + Lat + "&lon=" + Lng + "&radius=" + distance;

					APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					APIresponse = APIrequest.send();
					
					try {
						meetup_json = new JSONObject(APIresponse.getBody());
						Message JSON_message = new Message();
						JSON_message.setMessage(meetup_json);
						JSON_message.setUserKey(key);
						try {
							pm.makePersistent(JSON_message);

						} finally {
							pm.close();
						}
						

						names = JSONObject.getNames(meetup_json.getJSONArray("results").getJSONObject(0));
						for (int j = 0; j < meetup_json.getJSONArray("results").length(); j++) {
							resp.getWriter().println( "[<b>" + (j+1) + "</b>]<br>" );
							for (int i = 0; i < names.length; i++) {
								String temp = meetup_json.getJSONArray("results").getJSONObject(j).getString(names[i]);
								resp.getWriter().println(names[i] + ": " + temp + "<br>");
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
			resp.sendRedirect(callback);
		}

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