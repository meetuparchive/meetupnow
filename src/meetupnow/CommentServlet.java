package meetupnow;

import com.google.appengine.api.datastore.Key;

import java.io.IOException;
import java.util.Properties;
import java.util.List;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;

import org.scribe.oauth.*;
import org.scribe.http.*;
import org.apache.commons.codec.*;

import meetupnow.MeetupUser;
import meetupnow.NewsItem;
import meetupnow.PMF;


public class CommentServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String content = "";
		String ev_id = "";
		String callback = "";	
		String title = "";	

		if (req.getQueryString() != null) {
			content = req.getParameter("comment");
			ev_id = req.getParameter("id");
			callback = req.getParameter("callback");
			title = req.getParameter("title");
		}

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

		String API_URL = "http://api.meetup.com/ew/comment/";

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
				APIrequest.addBodyParameter("event_id",ev_id);
				APIrequest.addBodyParameter("comment", content);				

				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();

				//Create notification
				NewsItem notify = new NewsItem();
				notify.setType("comment");
				notify.setName(users.get(0).getName());
				notify.setMessage(content);
				notify.setLink("/Event?"+ev_id);
				notify.setEvConName(title);

				try {
					pm.makePersistent(notify);
				} finally {
					
				}
				
			}


		} finally {
			query.closeAll();
			pm.close();
			resp.sendRedirect(callback);
		}


	}

}
