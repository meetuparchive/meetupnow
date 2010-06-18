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
public class SetPrefsServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String callback = "";
		String mu_id = "";
		String email = "";
		String group = "";
		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			mu_id = req.getParameter("id");
			email = req.getParameter("email");
			group = req.getParameter("group");
		}
		javax.servlet.http.Cookie[] cookies = req.getCookies();

		String key = "empty";
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
					key = cookies[i].getValue();

        			}
      			}
    		}

		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(UserInfo.class);
		query.setFilter("user_id == idParam");
		query.declareParameters("String idParam");
		Transaction tx = pm.currentTransaction();
		try {
			tx.begin();
			List<UserInfo> profs = (List<UserInfo>) query.execute(mu_id);
			if (profs.iterator().hasNext()) {			
				if (email != null) {				
					profs.get(0).setEmail(email);
				}
				if (group != null) {
					profs.get(0).addGroup(group);
				}
				profs.get(0).incrementLoginCount();
			
			} else {
				//CREATE NEW
				UserInfo newUser = new UserInfo();
				newUser.setID(mu_id);	
				newUser.incrementLoginCount();
				try {
					pm.makePersistent(newUser);
				} finally {
						
				}
			}
			tx.commit();
		} catch (Exception e) {
			if (tx.isActive()) {
				tx.rollback();
			}	
		}
		finally {
			query.closeAll();
			pm.close();
			resp.sendRedirect(callback);
		}

	}
}
