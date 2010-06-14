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
		
	}
}
