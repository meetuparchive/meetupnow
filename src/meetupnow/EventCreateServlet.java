package meetupnow;

import com.google.appengine.api.datastore.Key;

import java.io.IOException;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.List;
import java.util.ArrayList;
import java.util.Calendar;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;

import org.scribe.oauth.*;
import org.scribe.http.*;
import org.scribe.encoders.URL;
import org.apache.commons.codec.*;
import org.json.*;

import meetupnow.MeetupUser;
import meetupnow.PMF;
import meetupnow.NewsItem;


public class EventCreateServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String c_id = "";
		String tz = "";
		String callback = "";
		String lat = "";
		String lon = "";
		String ad = "";
		String city = "";
		String state = "";
		String country = "";
		String month = "";
		String day = "";
		String year = "";
		String hour = "";
		String minute = "";
		String ampm = "";
		String venue = "";
		String desc = "";
		String name = "";
		String zip = "";
		String mTime = "";		

		if (req.getQueryString() != null) {
			mTime = req.getParameter("mtime");
			tz = req.getParameter("localTimeZone");
			callback = req.getParameter("callback");
			month = req.getParameter("month");
			day = req.getParameter("day");
			year = req.getParameter("year");
			hour = req.getParameter("hour");
			minute = req.getParameter("minute");
			venue = req.getParameter("venue");
			desc = req.getParameter("desc");
			c_id = req.getParameter("topic");
			name = req.getParameter("name");
			ampm = req.getParameter("ampm");
			lat = req.getParameter("lat");
			lon = req.getParameter("lon");
			ad = req.getParameter("address");
			city = req.getParameter("city");
			state = req.getParameter("state");
			country = req.getParameter("country");
			zip = req.getParameter("zip");


		}
		String millitime;
		if (mTime == null) {
			millitime= getMilliTime(year,month,day,hour,minute,ampm, tz);
		}
		else {
			millitime = mTime;
		}
		String rsvpID = "";
		String containerName = "";
		

		
		String API_URL = "http://api.meetup.com/ew/event/";
		String key = "empty";
    		javax.servlet.http.Cookie[] cookies = req.getCookies();

		


    		if (cookies != null) {
      			for (int i = 0; i < cookies.length; i++) {
        			if (cookies[i].getName().equals("meetup_access")) {
          				key = cookies[i].getValue();
        			}
      			}
    		}
		if (key.equals("empty")) {
			resp.sendRedirect("/oauth");
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
				Request APIrequest = new Request(Request.Verb.POST, API_URL);
				APIrequest.addBodyParameter("venue_name",venue);

				 	if (zip != null) {
						APIrequest.addBodyParameter("zip", zip);
						APIrequest.addBodyParameter("address1", ad.split(",")[0]);
					} else {
						APIrequest.addBodyParameter("lat", lat);
						APIrequest.addBodyParameter("lon", lon);
						APIrequest.addBodyParameter("address1", ad.split(",")[0]);
					}
				
				APIrequest.addBodyParameter("time",millitime);
				APIrequest.addBodyParameter("container_id",c_id);
				APIrequest.addBodyParameter("description",desc);
				APIrequest.addBodyParameter("title",name);
				APIrequest.addBodyParameter("fields","title");
				APIrequest.addBodyParameter("organize","true");
				

				scribe.signRequest(APIrequest,accessToken);
				Response APIresponse = APIrequest.send();
				
				JSONObject json = new JSONObject(APIresponse.getBody());
				rsvpID = json.getString("id");
				if (callback.contains("?")) {
					callback = callback.concat("&id="+rsvpID);
				}
				else {
					callback = callback.concat("?id="+rsvpID);
				}
				containerName = json.getJSONObject("container").getString("name");

				//Send email(s)
				String body = users.get(0).getName()+" posted a new event:\n"+name+"\nand it's in your area!\n\nMore Info: "+desc+"\n\nLINK: http://jake-meetup-test.appspot.com/Event?id="+rsvpID;

				ArrayList<String> emails = getEmailAddresses(c_id,Double.parseDouble(lat),Double.parseDouble(lon));

				for (int i = 0; i < emails.size(); i++) {
					EmailServlet.sendEmail(emails.get(i),"jgl2832@gmail.com","New event in your area: "+name,body);
				}
				//Create notification
				NewsItem notify = new NewsItem();
				notify.setType("event_create");
				notify.setName(users.get(0).getName());
				if (desc.length() > 100) {
					notify.setMessage(desc.substring(0,97).concat("..."));
				}
				else {
					notify.setMessage(desc);
				}
				notify.setLink("/Event?"+rsvpID);
				notify.setEvConName(name);
				notify.setContainerName(containerName);

				try {
					pm.makePersistent(notify);
				} finally {
					
				}
			}
		} catch (JSONException j){
			
		}
		finally {
			query.closeAll();
			pm.close();
			if (rsvpID.equals("")) {
				resp.sendRedirect(callback);
			}	
			else {
				resp.sendRedirect("/EventRegister?action=join&cid="+ c_id +"&id="+rsvpID+"&callback="+callback);
			}
		}

	}

	public static String getMilliTime(String year, String month, String day, String hour, String min, String ampm, String tz) {
		int dateHour;
		int timeZone = Integer.parseInt(tz);
		if (ampm.equals("am")) {
			if (hour.equals("12")) {
				dateHour = 0;
			} else {
				dateHour = Integer.parseInt(hour);
			}
		} else {
			if (hour.equals("12")) {
				dateHour = 12;
			} else {
				dateHour = Integer.parseInt(hour)+12;
			}
		}
		dateHour = dateHour + timeZone;			//Convert to GMT
		if (dateHour < 0) {
			dateHour = dateHour + 24;
		}
		Calendar cal = Calendar.getInstance();
		cal.set(Integer.parseInt(year),Integer.parseInt(month) - 1,Integer.parseInt(day) ,dateHour,Integer.parseInt(min));
		return ""+cal.getTimeInMillis();
	}


	public ArrayList<String> getEmailAddresses(String cID, double evLat, double evLon) {
		ArrayList<String> output = new ArrayList<String>();
		double plat;
		double plon;
		double radius;
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(UserInfo.class);
		//query.setFilter("((emailOpt == emailOptParam)||(cellOpt == cellOptParam))");
		query.declareParameters("boolean emailOptParam, boolean cellOptParam");
		try {
			List<UserInfo> profiles = (List<UserInfo>) query.execute(true,true);
			UserInfo temp;
			for (int i = 0; i < profiles.size(); i++) {
				temp = profiles.get(i);
				if (temp.isMember(cID)) {
					plat = Double.parseDouble(temp.getLat());
					plon = Double.parseDouble(temp.getLon());
					radius = Double.parseDouble(temp.getDistance());
					if (distance(plat,plon,evLat,evLon) <= radius) {
						if (temp.getEmailOpt()) {
							output.add(temp.getEmail());
						}
						if (temp.getCellOpt()) {
							if (temp.getCarrier().equals("att")) {
								output.add(temp.getCellNum()+"@txt.att.net");
							}
							else if (temp.getCarrier().equals("verizon")) {
								output.add(temp.getCellNum()+"@vtext.com");
							}
							else if (temp.getCarrier().equals("tmobile")) {
								output.add(temp.getCellNum()+"@tmomail.net");
							}
						}
					}
				}
			}
		} finally {
			query.closeAll();	
			return output;
		}

	}

	private double distance(double lat1, double lon1, double lat2, double lon2) {
  		double theta = lon1 - lon2;
  		double dist = Math.sin(deg2rad(lat1)) * Math.sin(deg2rad(lat2)) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.cos(deg2rad(theta));
  		dist = Math.acos(dist);
  		dist = rad2deg(dist);
 		dist = dist * 60 * 1.1515;
  		return (dist);
	}

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*::  This function converts decimal degrees to radians             :*/
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
	private double deg2rad(double deg) {
  		return (deg * Math.PI / 180.0);	
	}

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*::  This function converts radians to decimal degrees             :*/
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
	private double rad2deg(double rad) {
  		return (rad * 180.0 / Math.PI);
	}




}
