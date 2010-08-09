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
import org.json.*;
import java.util.Properties;

//TO DO: Delete user objects from databank
public class SetPrefsServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String callback = "";
		String mu_id = "";
		String email = "";
		String group = "";
		String action = "";	
		String distance = "";
		String cell = "";
		String carrier = "";
		String cellOpt = "";
		String emailOpt = "";
		String zip = "";
		String lat = "";
		String lon = "";

		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			mu_id = req.getParameter("id");
			email = req.getParameter("email");
			group = req.getParameter("group");
			action = req.getParameter("action");
			distance = req.getParameter("distance");
			cell = req.getParameter("cell");
			carrier = req.getParameter("carrier");
			cellOpt = req.getParameter("cellOpt");
			emailOpt = req.getParameter("emailOpt");
			zip = req.getParameter("zip");
			lat = req.getParameter("lat");
			lon = req.getParameter("lon");
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
			if (profs.size() > 0) {			
				if (email != null) {				
					profs.get(0).setEmail(email);
				}
				if (group != null) {
					if (action.equals("remove")) {
						profs.get(0).removeGroup(group);
					} else if (action.equals("add")){
						profs.get(0).addGroup(group);
						setAlerts(group, pm, key);
					} else if (action.equals("update")) {
						setAlerts(group, pm, key);
					}
				}
				if (cell != null) {
					profs.get(0).setCellNum(cell);
				}
				if (carrier != null) {
					profs.get(0).setCarrier(carrier);
				}
				if (distance != null) {
					profs.get(0).setDistance(distance);
				}
				if (zip != null) {
					profs.get(0).setZip(zip);
				}
				if (lat != null) {
					profs.get(0).setLat(lat);
				}
				if (lon != null) {
					profs.get(0).setLon(lon);
				}
				if (cellOpt != null) {
					if (cellOpt.equals("yes")) {profs.get(0).setCellOpt(true);}
					else if (cellOpt.equals("no")) {profs.get(0).setCellOpt(false);}
				}
				if (emailOpt != null) {
					if (emailOpt.equals("yes")) {profs.get(0).setEmailOpt(true);}
					else if (emailOpt.equals("no")) {profs.get(0).setEmailOpt(false);}
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

	//Sets the current user's default MU alerts for the container to false.
	public void setAlerts(String id, PersistenceManager pm, String key) {
		Properties prop = new Properties();
		prop.setProperty("consumer.key","830E4150F3098788A8F99282A2E2D93D");
		prop.setProperty("consumer.secret","E882A57A98B1F5A477B7A4136BEF8A32");
		Scribe scribe = new Scribe(prop);

		Query query = pm.newQuery(MeetupUser.class);
		query.setFilter("accToken == accTokenParam");
		query.declareParameters("String accTokenParam");

		try {
			List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
			if (users.iterator().hasNext()) {
				Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
				String API_URL = "http://api.meetup.com/ew/container/"+id+"/alerts";
				Request APIrequest = new Request(Request.Verb.POST, API_URL);
				APIrequest.addBodyParameter("comments","false");
				APIrequest.addBodyParameter("rsvps","false");
				APIrequest.addBodyParameter("updates","false");

				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
			}
		}
		finally {
			query.closeAll();
		}

	}
}
