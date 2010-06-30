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
import java.lang.*;

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
		
		boolean IsNewTopic = false;

		String name = "";
		String callback = "";
		String desc = "";
		String keyWords ="";
		
		//get parameters
		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			desc = req.getParameter("desc");
			name = req.getParameter("name");
			keyWords = req.getParameter("keywords");


		}

		
		String API_URL = "http://api.meetup.com/ew/container/";
		String key = "empty";
    		javax.servlet.http.Cookie[] cookies = req.getCookies();

		//check if user logged in
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

		//query user
		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");
		
		//query topic
		Query TopicQuery = pm.newQuery(Topic.class);
		TopicQuery.setFilter("name == nameParam");
		TopicQuery.declareParameters("String nameParam");
	
		String rsvpID = "";

		try {

			//get user and topic
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			List<Topic> Topics = (List<Topic>) TopicQuery.execute(name);

			//check if topic in database
			if (Topics.isEmpty()){
				
				//check if user in database
				if (users.iterator().hasNext()) {

					//make api call to create new container
					Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
					Request APIrequest = new Request(Request.Verb.POST, API_URL);
					APIrequest.addBodyParameter("description",desc);
					APIrequest.addBodyParameter("name",name);
					APIrequest.addBodyParameter("event_create","anyone");
					APIrequest.addBodyParameter("link","http://www.jake-meetup-test.appspot.com/");
					APIrequest.addBodyParameter("link_name", "Meetup Now");
				
					scribe.signRequest(APIrequest,accessToken);
					Response APIresponse = APIrequest.send();
				
					JSONObject json = new JSONObject(APIresponse.getBody());

					//try to get response from api call
					try {	

						//if container name not taken on meetup database add it to our database				
						rsvpID = json.getString("id");


						Topic NewTopic = new Topic(desc, users.get(0).getID(), name, Integer.parseInt(rsvpID));
						NewTopic.setKeyWords(keyWords);
						try {
							pm.makePersistent(NewTopic);
						} finally {
							IsNewTopic = true;
							pm.close();
						}
		
					
					} catch (JSONException j){

						//topic name taken
						rsvpID = "";
					}

				}
				else {

					//user name not in database
					resp.sendRedirect("/OAuth");

				}
			} else {

				//topic already in our database
				rsvpID = Integer.toString(Topics.get(0).getId());

			}
		} catch (JSONException j){

		}
		finally {

			//finally check if new topic was made
			query.closeAll();

			if (rsvpID.equals("")) {
				resp.sendRedirect("/errors/NewTopicError.jsp");
			}	
			else {
				if (IsNewTopic){

					//send to new topic page
					resp.sendRedirect("/Topic?" + rsvpID);
				} else{

					//send to error page with id
					resp.sendRedirect("/errors/NewTopicError.jsp?" + rsvpID);
				}
			}
		}

	}

	public static String getMilliTime(String year, String month, String day, String hour, String min) {
		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(year),Integer.parseInt(month) - 1,Integer.parseInt(day) +1 ,Integer.parseInt(hour),Integer.parseInt(min));
		return ""+cal.getTimeInMillis();
	}


}
