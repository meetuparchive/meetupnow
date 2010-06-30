package meetupnow;

import javax.servlet.http.*;
import java.io.IOException;
import java.util.Properties;
import java.util.List;
import java.util.Date;
import java.util.ArrayList;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.jdo.Query;

import org.scribe.oauth.*;
import org.scribe.http.*;
import org.json.*;

public class LuckyEventServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		RegDev sg = new RegDev();
		String topicList = getContainerList();

		String API_URL = "http://api.meetup.com/ew/events/?status=upcoming&fields=geo_ip,rsvp_count&" + topicList;

		Response APIresponse = sg.submitURL(API_URL);
		JSONObject json = new JSONObject();

		double[] distanceArray;			//smaller = better
		double[] timeBetweenArray;		//smaller = better
		int[] RSVPcountArray;			//larger = better
		try {
			json = new JSONObject(APIresponse.getBody());
			JSONObject meta = json.getJSONObject("meta");
			JSONArray results = json.getJSONArray("results");

			double metaLat = Double.parseDouble(meta.getJSONObject("geo_ip").getString("lat"));
			double metaLon = Double.parseDouble(meta.getJSONObject("geo_ip").getString("lon"));
			Date now = new Date();
			long then;
			double itemLat;
			double itemLon;
			double timeBetween;
			int rsvpCount;

			int best = 0;
			double bestVal = 0;
			double tempScore;

			distanceArray = new double[results.length()];
			timeBetweenArray = new double[results.length()];
			RSVPcountArray = new int[results.length()];
			for (int i = 0; i < results.length(); i++) {
				then = Long.parseLong(results.getJSONObject(i).getString("time"));
				itemLat = Double.parseDouble(results.getJSONObject(i).getString("lat"));
				itemLon = Double.parseDouble(results.getJSONObject(i).getString("lon"));
				rsvpCount = Integer.parseInt(results.getJSONObject(i).getString("rsvp_count"));
				timeBetween = hoursBetween(then,now.getTime());
				
				distanceArray[i] = distance(metaLat,metaLon,itemLat,itemLon);
				timeBetweenArray[i] = timeBetween;
				RSVPcountArray[i] = rsvpCount;
				tempScore = score(timeBetweenArray[i],distanceArray[i],RSVPcountArray[i]);
				if (tempScore > bestVal) {
					best = i;
					bestVal = tempScore;
				}
			}
			resp.sendRedirect("Event?"+results.getJSONObject(best).getString("id"));
		} catch (JSONException j) {}
	}

	public String getContainerList() {
		PersistenceManager pm = PMF.get().getPersistenceManager();

		String TopicList = "container_id=";
		Query TopicQuery = pm.newQuery(Topic.class);
		TopicQuery.setFilter("id != 0");
		TopicQuery.declareParameters("String reqTokenParam");	//Setup Query

		List<Topic> Topics = new ArrayList<Topic>();
		try {
			Topics = (List<Topic>) pm.detachCopyAll((List<Topic>) TopicQuery.execute(""));
			for (int i = 0; i < Topics.size(); i++){
				TopicList = TopicList + Integer.toString(Topics.get(i).getId()) + ",";
			}
			if (TopicList.charAt(TopicList.length() - 1) == ',')
				TopicList = TopicList.substring(0, TopicList.length() - 1);
		} finally {
			pm.close();
		}
		
		return TopicList;
	}

	public static double distance(double lat1, double lon1, double lat2, double lon2) {
		double R = 6371; // km
		double dLat = (lat2-lat1)*(Math.PI / 180);
		double dLon = (lon2-lon1)*(Math.PI / 180); 
		double a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon/2) * Math.sin(dLon/2); 
		double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
		double d = R * c * 0.621371192;

		return d;
	}  

	//Returns time away in hours
	public static long hoursBetween(long now, long then){
	
		long seconds = (now - then)/1000;
		long minutes = seconds/60;
		long hours = minutes/60;

		return hours;

	}

	public double score(double time, double distance, double rsvpcount) {
		double timeScaleMax = 200;
		double timeScaleRange = 750; 
		double distanceScaleMax = 50;
		double distanceScaleRange = 2000;
		double rsvpScale = 1;
		
		double t = timeScaleMax * Math.pow(Math.E,-1*(time*time/timeScaleRange));
		double d = distanceScaleMax * Math.pow(Math.E,-1*(distance*distance/distanceScaleRange));
		double r = rsvpcount * rsvpScale;	

		return t + d + r;
	}

}

