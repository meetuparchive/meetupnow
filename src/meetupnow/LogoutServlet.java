package meetupnow;

import javax.servlet.http.*;
import javax.servlet.http.Cookie;

import java.io.IOException;
import java.util.List;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;
import org.scribe.oauth.*;
import org.scribe.http.*;
import java.util.Properties;

//TO DO: Delete user objects from databank
public class LogoutServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String callback = "";
		if (req.getQueryString() != null) {
			callback = OAuthServlet.getArg("callback",req.getQueryString());
		}
		javax.servlet.http.Cookie[] cookies = req.getCookies();

		String key = "empty";
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
					key = cookies[i].getValue();

          				cookies[i].setMaxAge(0);
					cookies[i].setPath(req.getContextPath());
					cookies[i].setValue("");
					resp.addCookie(cookies[i]);
        			}
      			}
    		}

		Properties prop = new Properties();
		prop.setProperty("consumer.key","12345");
		prop.setProperty("consumer.secret","67890");
		Scribe scribe = new Scribe(prop);
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");

		Transaction tx = pm.currentTransaction();
		try {
			tx.begin();
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			if (users.iterator().hasNext()) {				
				pm.deletePersistent(users.get(0));
				
			}
			tx.commit();
		} catch (Exception e) {
			if (tx.isActive()) {
				tx.rollback();
			}
		}
		finally {
			query.closeAll();
			resp.sendRedirect(callback);
		}

	}


}
