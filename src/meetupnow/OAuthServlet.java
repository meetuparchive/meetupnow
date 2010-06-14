package meetupnow;

import com.google.appengine.api.datastore.Key;

import java.io.IOException;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.List;

import org.scribe.oauth.*;

import org.apache.commons.codec.*;

import meetupnow.MeetupUser;
import meetupnow.PMF;

import javax.servlet.http.Cookie;

public class OAuthServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		
		String token = "";
		String verify = "";
		String callback = "/";
		if (req.getQueryString() != null) {
			token = getArg("oauth_token",req.getQueryString());
			verify = getArg("oauth_verifier",req.getQueryString());
			callback = getArg("callback",req.getQueryString());
		}

		Properties prop = new Properties();
		prop.setProperty("consumer.key","12345");
		prop.setProperty("consumer.secret","67890");
		prop.setProperty("request.token.verb","POST");
		prop.setProperty("request.token.url","http://www.meetup.com/oauth/request/");
		prop.setProperty("access.token.verb","POST");
		prop.setProperty("access.token.url","http://www.meetup.com/oauth/access/");
		prop.setProperty("callback.url",req.getRequestURL().toString());

		//Create scribe object
		Scribe scribe = new Scribe(prop);

		PersistenceManager pm = PMF.get().getPersistenceManager();

		if (!token.equals("")) {  //If access key is obtained

			Token requestToken = null;

			Query query = pm.newQuery(MeetupUser.class);
			query.setFilter("reqToken == reqTokenParam");
			query.declareParameters("String reqTokenParam");

			Transaction tx = pm.currentTransaction();
			try {
				tx.begin();
				List<MeetupUser> users = (List<MeetupUser>) query.execute(token);
				if (users.iterator().hasNext()) {
					requestToken = new Token(users.get(0).getReqToken(),users.get(0).getReqTokenSecret());
					Token accessToken = scribe.getAccessToken(requestToken, verify);
					users.get(0).setAccToken(accessToken.getToken());
					users.get(0).setAccTokenSecret(accessToken.getSecret());

					//SETCOOKIE
					Cookie c = new Cookie("meetup_access", accessToken.getToken());
      					resp.addCookie(c);
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
			
			

		} else {
			//Get request Token
			Token requestToken = scribe.getRequestToken();

			MeetupUser newUser = new MeetupUser();
			newUser.setReqToken(requestToken.getToken());		
			newUser.setReqTokenSecret(requestToken.getSecret());
			try {
				pm.makePersistent(newUser);
			} finally {
				pm.close();
			}
		
			resp.sendRedirect("http://www.meetup.com/authorize/?callback="+callback+"&oauth_token="+requestToken.getToken());
		
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
