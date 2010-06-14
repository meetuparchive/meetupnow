package meetupnow;

import com.google.appengine.api.datastore.Key;

import org.scribe.oauth.Token;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;

import java.io.IOException;
import javax.servlet.http.*;
import javax.servlet.http.Cookie;

import java.util.Properties;
import java.util.StringTokenizer;
import java.util.List;

import org.scribe.oauth.*;
import org.apache.commons.codec.*;
import org.json.*;

import meetupnow.MeetupUser;
import meetupnow.PMF;



@PersistenceCapable
public class MeetupUser {
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	@Persistent
	private String reqToken;

	@Persistent
	private String reqTokenSecret;

	@Persistent
	private String accToken;

	@Persistent
	private String accTokenSecret;

	public MeetupUser() {
		reqToken = null;
		reqTokenSecret = null;
		accToken = null;
		accTokenSecret = null;
	}

   	public Key getKey() {
    	    	return key;
    	}

	public String getReqToken() {
		return reqToken;
	}

	public String getReqTokenSecret() {
		return reqTokenSecret;
	}

	public void setReqToken(String r) {
		reqToken = r;
	}

	public void setReqTokenSecret(String a) {
		reqTokenSecret = a;
	}


	public String getAccToken() {
		return accToken;
	}

	public String getAccTokenSecret() {
		return accTokenSecret;
	}

	public void setAccToken(String r) {
		accToken = r;
	}

	public void setAccTokenSecret(String a) {
		accTokenSecret = a;
	}

	public void CreateEvent(int container_id, int lat, int lon){
		String key = "empty";
    		Cookie[] cookies = request.getCookies();
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
			response.sendRedirect("/test");
		}	
		
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
				Request APIrequest = new Request(Request.Verb.GET, "http://api.meetup.com/groups.json/?zip=11211&page=5&order=ctime&desc=true");
				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				
			}
		}
		finally {
			query.closeAll();
		}
%>
	} 
}
