package meetupnow;

import java.io.IOException;
import javax.servlet.http.*;


public class MeetupNowServlet extends HttpServlet {
     public void doGet(HttpServletRequest req, HttpServletResponse resp)
              throws IOException {
	
	RegDev sg = new RegDev();
	String URL = "http://api.meetup.com/ew/events?container_id=713&status=upcoming";

	System.out.println(sg.generateURL(URL));
    }

}
