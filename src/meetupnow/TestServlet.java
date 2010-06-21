package meetupnow;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.http.*;
import javax.servlet.ServletOutputStream;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import Acme.JPM.Encoders.GifEncoder;
import java.awt.Frame;
import java.awt.Graphics;
import java.awt.Image;


public class TestServlet extends HttpServlet {
     	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		ServletOutputStream gifout = resp.getOutputStream();


		Frame frame=null;
		Graphics g = null;

		try{
			//create an unshown frame
			frame = new Frame();
			frame.addNotify();
 
			//get graphics context from this dummy frame
			Image image=frame.createImage(600,60);
			g=image.getGraphics();
 
			//draw the line
			g.drawLine(10,30,590,30);
 	
			resp.setContentType("image/gif");
			GifEncoder encoder = new GifEncoder(image, gifout);
			encoder.encode();

		}finally{
			//cleanup:
			if (g!=null) g.dispose();
			if (frame!=null) frame.removeNotify();
		}
 

	}

}
