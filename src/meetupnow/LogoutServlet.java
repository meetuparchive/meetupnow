package meetupnow;

import javax.servlet.http.*;
import javax.servlet.http.Cookie;

import java.io.IOException;

public class LogoutServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		String callback = "";
		if (req.getQueryString() != null) {
			callback = OAuthServlet.getArg("callback",req.getQueryString());
		}
		javax.servlet.http.Cookie[] cookies = req.getCookies();
    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				cookies[i].setMaxAge(0);
					cookies[i].setPath(req.getContextPath());
					cookies[i].setValue("");
					resp.addCookie(cookies[i]);
        			}
      			}
    		}

		resp.sendRedirect(callback);
	}


}
