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
import meetupnow.NewsItem;


public class EventRegisterServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String ev_id = "";
		String callback = "";
		String action = "";
		String r_id = "";
		String c_id = "";
		if (req.getQueryString() != null) {
			action = req.getParameter("action");
			r_id = req.getParameter("r_id");
			ev_id = req.getParameter("id");
			callback = req.getParameter("callback");
			c_id = req.getParameter("cid");
		}

		String API_URL = "http://api.meetup.com/ew/rsvp/?event_id="+ev_id;
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

		String mu_id = "";

		String username = "";
		String evName = "";
		String conName = "";
		String link = "";

		Transaction tx = pm.currentTransaction();
		try {
			tx.begin();
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			if (users.iterator().hasNext()) {
				Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
				Request APIrequest = new Request(Request.Verb.POST, API_URL);
				String url2 = "http://api.meetup.com/ew/events/?event_id="+ev_id;
				Request APIrequest2 = new Request(Request.Verb.GET, url2);

				scribe.signRequest(APIrequest,accessToken);
				scribe.signRequest(APIrequest2,accessToken);

				Response APIresponse = APIrequest.send();
				Response ev_res = APIrequest2.send();

				JSONObject json = new JSONObject(ev_res.getBody());
				JSONObject ev = json.getJSONArray("results").getJSONObject(0);


				users.get(0).addEvent(ev_id);
				mu_id = users.get(0).getID();
	
				username = users.get(0).getName();
				try {
					evName = ev.getString("title");
				} catch (Exception e) {

				}
				
				conName = ev.getJSONObject("container").getString("name");

			}
			tx.commit();

			//Create notification
			NewsItem notify = new NewsItem();
			notify.setType("event_rsvp");
			notify.setName(username);
			notify.setLink("/Event?"+ev_id);
			notify.setEvConName(evName);
			notify.setContainerName(conName);
			try {
				pm.makePersistent(notify);
			} finally {
				
			}
		} catch (Exception e) {
			if (tx.isActive()) {
				tx.rollback();
			}
		}
		finally {
			query.closeAll();
			pm.close();
			resp.sendRedirect("/setprefs?callback="+callback+"&action=update&group="+c_id+"&id="+mu_id);
		}

	}

}
