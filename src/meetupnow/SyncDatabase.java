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


public class SyncDatabase extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

			String API_URL = "http://api.meetup.com/ew/containers?order=name&fields=rsvp_count&offset=0&link=http%3A%2F%2Fjake-meetup-test.appspot.com";
			RegDev sg = new RegDev();
			Response APIresponse = sg.submitURL(API_URL);

			JSONArray top_list;	

			PersistenceManager pm = PMF.get().getPersistenceManager();
			String TopicList = "container_id=";
			Query TopicQuery = pm.newQuery(Topic.class);
			TopicQuery.setFilter("id != 0");
			TopicQuery.declareParameters("String reqTokenParam");	//Setup Query

			List<Topic> Topics = new ArrayList<Topic>();
			try {
				Topics = (List<Topic>) pm.detachCopyAll((List<Topic>) TopicQuery.execute("z"));
				for (int i = 0; i < Topics.size(); i++){
					TopicList = TopicList + Integer.toString(Topics.get(i).getId()) + ",";
				}
				if (TopicList.charAt(TopicList.length() - 1) == ',')
					TopicList = TopicList.substring(0, TopicList.length() - 1);
			} finally {

			}

				
		Topic NewTopic;


		try{
			JSONObject json = new JSONObject(APIresponse.getBody());
			top_list = json.getJSONArray("results");
			boolean found = false;
			for (int j = 0; j < top_list.length(); j++){
				found = false;
				for (int i = 0; i < Topics.size(); i++){
					if( Integer.parseInt(top_list.getJSONObject(j).getString("id")) == Topics.get(i).getId() ){
						found = true;
					}
				}
				if (!found){
					NewTopic = new Topic(top_list.getJSONObject(j).getString("description"), top_list.getJSONObject(j).getJSONObject("founder").getString("member_id"), top_list.getJSONObject(j).getString("name"), Integer.parseInt(top_list.getJSONObject(j).getString("id")));
					try {
						pm.makePersistent(NewTopic);
						System.out.println(NewTopic.getId());
					} 
				
					finally {

					}
				}
			}

		}
		catch (JSONException j){

		}
	}
}
