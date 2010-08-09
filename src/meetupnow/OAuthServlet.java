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
import org.scribe.http.*;
import org.apache.commons.codec.*;

import meetupnow.MeetupUser;
import meetupnow.PMF;
import org.json.*;
import javax.servlet.http.Cookie;

public class OAuthServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		
		//Get arguments from query line: request token, verifier, and a callback URL
		String m_id = "";
		
		String token = "";
		String verify = "";
		String callback = "";
		if (req.getQueryString() != null) {
			token = getArg("oauth_token",req.getQueryString());
			verify = getArg("oauth_verifier",req.getQueryString());
			callback = getArg("callback",req.getQueryString());
		}

		//Set the properties of the Scribe Object
		Properties prop = new Properties();
		prop.setProperty("consumer.key","830E4150F3098788A8F99282A2E2D93D");
		prop.setProperty("consumer.secret","E882A57A98B1F5A477B7A4136BEF8A32");
		prop.setProperty("request.token.verb","POST");
		prop.setProperty("request.token.url","http://www.meetup.com/oauth/request/");
		prop.setProperty("access.token.verb","POST");
		prop.setProperty("access.token.url","http://www.meetup.com/oauth/access/");
		prop.setProperty("callback.url",req.getRequestURL().toString()+"?callback="+callback);


		Scribe scribe = new Scribe(prop);				//Create Scribe Object
		PersistenceManager pm = PMF.get().getPersistenceManager();	//Initialize Persistance Manager
		if (!token.equals("")) {  //If access key is obtained

			Token requestToken = null;
			Query query = pm.newQuery(MeetupUser.class);
			query.setFilter("reqToken == reqTokenParam");
			query.declareParameters("String reqTokenParam");	//Setup Query
			Transaction tx = pm.currentTransaction();		//Begin Transaction
			try {
				tx.begin();
				List<MeetupUser> users = (List<MeetupUser>) query.execute(token);	//Execute Query
				if (users.iterator().hasNext()) {
					//Recreate requestToken and get Access Token
					requestToken = new Token(users.get(0).getReqToken(),users.get(0).getReqTokenSecret());
					Token accessToken = scribe.getAccessToken(requestToken, verify);
					users.get(0).setAccToken(accessToken.getToken());
					users.get(0).setAccTokenSecret(accessToken.getSecret());

					//GET USER INFO
					String API_URL = "http://api.meetup.com/members/?relation=self";
					//Sign request and get user info response
					Request APIrequest = new Request(Request.Verb.GET, API_URL);
					scribe.signRequest(APIrequest,accessToken);
					Response APIresponse = APIrequest.send();
					JSONObject json = new JSONObject();
					JSONObject user;
					try {
						json = new JSONObject(APIresponse.getBody());
						user = json.getJSONArray("results").getJSONObject(0);
	                    if (user != null) {
						    users.get(0).setName(user.getString("name"));
						    users.get(0).setID(user.getString("id"));
						    m_id = user.getString("id");
						    users.get(0).setLat(user.getString("lat"));
						    users.get(0).setLon(user.getString("lon"));

                            //SETCOOKIE - if user exists
					        Cookie c = new Cookie("meetup_access", accessToken.getToken());
      					    resp.addCookie(c);
                        }
						
				
					} catch (JSONException j) {
						//User does not exist?
					}
					//GET RSVP INFO
					String RSVP_URL = "http://api.meetup.com/ew/rsvps/?member_id="+users.get(0).getID();
					//Request all RSVPs to populate database, save API calls later
					Request RSVPrequest = new Request(Request.Verb.GET, RSVP_URL);
					scribe.signRequest(RSVPrequest,accessToken);
					Response RSVPresponse = RSVPrequest.send();
					JSONObject json2 = new JSONObject();
					JSONArray ev_list;
					try {
						json2 = new JSONObject(RSVPresponse.getBody());
						ev_list = json2.getJSONArray("results");
						for (int i = 0; i < ev_list.length(); i++) {	
							users.get(0).addEvent(ev_list.getJSONObject(i).getString("event_id"));	
						}
					} catch (JSONException j) {
		
					}
				
				}
				//End Transaction
				tx.commit();
			} catch (Exception e) {
				if (tx.isActive()) {
					tx.rollback();
				}
			}
			finally {
				query.closeAll();
                pm.close();
				resp.sendRedirect("/setprefs?callback="+callback+"&id="+m_id);
			}
			

		} else {	//IF NOT LOGGED IN - create new user session in database
			//Get request Token
			Token requestToken = scribe.getRequestToken();

			MeetupUser newUser = new MeetupUser();
			newUser.setReqToken(requestToken.getToken());		
			newUser.setReqTokenSecret(requestToken.getSecret());
			try {
				pm.makePersistent(newUser);
			} finally {
				pm.close();
			    //Authorize token and redirect here
			    resp.sendRedirect("http://www.meetup.com/authorize/?callback="+callback+"&oauth_token="+requestToken.getToken());
			}

		
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
