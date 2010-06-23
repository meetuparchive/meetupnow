package meetupnow;

import javax.servlet.http.*;
import java.io.IOException;

import java.util.Properties;
import org.apache.commons.mail.*;
public class EmailServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
 		resp.setContentType("text/html");
		
		String from = "jgl2832@gmail.com";
		String to = "jake@meetup.com";
		
		try {
			SimpleEmail email=new SimpleEmail();
			email.setHostName("mail.meetup.com");
			email.setAuthentication("jake","n64gbc");
			email.setFrom("jake@meetup.com","Jake Levine");
			email.addTo("jake.levine@mail.mcgill.ca");
			email.setSubject("This is a Test");
			email.setMsg("This is a message, and its a test");
			email.send();
	
			resp.getWriter().println("BAM");
		} catch (EmailException e) {
			System.out.println(e);
		}

	}

}
