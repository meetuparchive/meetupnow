package meetupnow;

import javax.servlet.http.*;
import java.io.IOException;

import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
 		resp.setContentType("text/html");
		
		String from = "jgl2832@gmail.com";
		String to = "jake@meetup.com";
		
		Properties props = new Properties();
        	Session session = Session.getDefaultInstance(props, null);

        	String msgBody = "...asdfasdfasdf";

        	try {
            		Message msg = new MimeMessage(session);
            		msg.setFrom(new InternetAddress(from, "Example.com Admin"));
            		msg.addRecipient(Message.RecipientType.TO, new InternetAddress(to, "Mr. User"));
       			msg.setSubject("Your Example.com account has been activated");
            		msg.setText(msgBody);
            		Transport.send(msg);

        	} catch (Exception e) {
           		 // ...
       	 	}

	}

}
