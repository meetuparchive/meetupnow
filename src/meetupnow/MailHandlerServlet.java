package meetupnow;

import java.io.IOException; 
import java.util.Properties; 
import javax.mail.Session; 
import javax.mail.Multipart;
import javax.mail.BodyPart;
import javax.mail.internet.MimeMessage; 
import javax.servlet.http.*; 
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

public class MailHandlerServlet extends HttpServlet { 
    	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException { 
        	Properties props = new Properties(); 
        	Session session = Session.getDefaultInstance(props, null); 
		PersistenceManager pm = PMF.get().getPersistenceManager();
		try {


        		MimeMessage message = new MimeMessage(session, req.getInputStream());
			Suggestion sug = new Suggestion();
			String output = "";
	 		Object content  = message.getContent();   
   			if(content instanceof String ) {       
				output = ((String) message.getContent());
   			} else if (content instanceof Multipart)  {   
           			Multipart mp = (Multipart)content;             
           			int parts = mp.getCount();       
           			BodyPart bodyPart = mp.getBodyPart(0);            
				Object o2 = bodyPart.getContent(); 
				output = output.concat((String) o2);
   			}  

			sug.setTo(message.getAllRecipients()[0].toString());
			sug.setContent(output);
			sug.setSubject(message.getSubject());
			sug.setAddress(message.getFrom()[0].toString());
			try {
				pm.makePersistent(sug);
			} finally {
				pm.close();
			}




		} catch (Exception e) {
			System.out.println(e);		
		}	
	}
}
