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
		String to = "";
		String cell = "";
		String carr = "";
		String callback = "";

		if (req.getQueryString() != null) {
			callback = req.getParameter("callback");
			to = req.getParameter("to");
			cell = req.getParameter("cell");
			carr = req.getParameter("carrier");
		}
		
		Properties props = new Properties();
        	Session session = Session.getDefaultInstance(props, null);
		Message msg;
		String msgSubject = "Did you get this?";
        	String msgBody = "TEST MESSAGE";


        	try {
			if (to != null) {
			        msg = new MimeMessage(session);
            			msg.setFrom(new InternetAddress(from, "Meetup Now"));
				msg.addRecipient(Message.RecipientType.TO, new InternetAddress(to, "Your name"));
       				msg.setSubject(msgSubject);
            			msg.setText(msgBody);
            			Transport.send(msg);
			}

			if ((cell != null)&&(carr != null)) {
				String address;
				//Parse cell number
				if (carr.equals("att")) {
					address = cell+"@txt.att.net";
					msg = new MimeMessage(session);
            				msg.setFrom(new InternetAddress(from, "Meetup Now"));
					msg.addRecipient(Message.RecipientType.TO, new InternetAddress(address, "Mr. User"));
       					msg.setSubject(msgSubject);
            				msg.setText(msgBody);
            				Transport.send(msg);
				}

				
			}

            		


        	} catch (Exception e) {
           		 // ...
       	 	} finally {
			resp.sendRedirect(callback);
		}

	}

	public static void sendEmail(String to, String from, String subject, String body) {

		Properties props = new Properties();
        	Session session = Session.getDefaultInstance(props, null);
		Message msg;

        	try {
			        msg = new MimeMessage(session);
            			msg.setFrom(new InternetAddress(from, "Meetup Now"));
				msg.addRecipient(Message.RecipientType.TO, new InternetAddress(to, "MeetupNow User"));
       				msg.setSubject(subject);
            			msg.setText(body);
            			Transport.send(msg);


            		


        	} catch (Exception e) {
           		 // ...
       	 	}
	}
}
