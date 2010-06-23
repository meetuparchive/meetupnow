package meetupnow;

import javax.servlet.http.*;
import javax.servlet.http.Cookie;



public class MUCookie {

	public static String getCookie(javax.servlet.http.Cookie[] c) {

    		//javax.servlet.http.Cookie[] cookies = request.getCookies();

    		if (c != null) {
      			for (int i = 0; i < c.length; i++) {
        			if (c[i].getName().equals("meetup_access")) {
          				return c[i].getValue();
        			}
      			}
    		}

		return "empty";
	}
}
