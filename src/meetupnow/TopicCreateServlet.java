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
import meetupnow.Topic;


public class TopicCreateServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String name = "";
		String callback = "";
		String desc = "";
		
		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			desc = req.getParameter("desc");
			name = req.getParameter("name");

		}

		
		String API_URL = "http://api.meetup.com/ew/container/";
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
		
		Query TopicQuery = pm.newQuery( Topic.class);
		TopicQuery.setFilter("name == nameParam");
		TopicQuery.declareParameters("String nameParam");
	
		String rsvpID = "";

		try {
			System.out.println(key);
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			List<Topic> Topics = (List<Topic>) query.execute(name);
			if (Topics.isEmpty()){

				if (users.iterator().hasNext()) {

					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					Request APIrequest = new Request(Request.Verb.POST, API_URL);
					APIrequest.addBodyParameter("description",desc);
					APIrequest.addBodyParameter("name",name);
					APIrequest.addBodyParameter("event_create","anyone");
				
					scribe.signRequest(APIrequest,accessToken);
					Response APIresponse = APIrequest.send();
				
					JSONObject json = new JSONObject(APIresponse.getBody());
					rsvpID = json.getString("id");
					Topic NewTopic = new Topic();
					System.out.println(json.toString());
				}
				else {
					System.out.println(users.isEmpty());
				}
			} else {
				System.out.println(Topics);
				rsvpID = "";

			}
		} catch (JSONException j){
			System.out.println(j);
		}
		finally {
			query.closeAll();
			System.out.println("finally");
			if (rsvpID.equals("")) {
				//resp.sendRedirect(callback);
			}	
			else {
				//resp.sendRedirect("/EventRegister?id="+rsvpID+"&callback="+callback);
			}
		}

	}

	public static String getMilliTime(String year, String month, String day, String hour, String min) {
		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(year),Integer.parseInt(month) - 1,Integer.parseInt(day) +1 ,Integer.parseInt(hour),Integer.parseInt(min));
		return ""+cal.getTimeInMillis();
	}


}
