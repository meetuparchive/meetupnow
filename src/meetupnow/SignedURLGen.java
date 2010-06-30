package meetupnow;

import org.scribe.oauth.*;
import org.scribe.http.*;
import org.json.*;

public class SignedURLGen {

	private String muKey;

	public SignedURLGen(String key) {
		muKey = key;
	}


	/* ALL METHODS TAKE UNSIGNED URLS AS ARGS*/

	//Returns empty string if it fails
	public String generateURL(String URLin) {
		String API_URL = URLin+"&sign=true&key="+muKey;	
		String out = "";
		try {
			Request APIrequest = new Request(Request.Verb.GET, API_URL);
			Response APIresponse = APIrequest.send();

			JSONObject json = new JSONObject(APIresponse.getBody());
			out = json.getJSONObject("meta").getString("signed_url");
			
		} catch (JSONException j) {

		}
		return out;
	}
	
	//Returns the full JSON Object of the call
	public Response submitURL(String URLin) {
		String API_URL = URLin+"&sign=true&key="+muKey;	
		Response APIresponse = null;
		try {
			Request APIrequest = new Request(Request.Verb.GET, API_URL);
			APIresponse = APIrequest.send();
			
		} catch (Exception j) {

		}
		return APIresponse;
	}
	
	public Response submitUnsignedURL(String URLin) {
		Response APIresponse = null;
		try {
			Request APIrequest = new Request(Request.Verb.GET, URLin);
			APIresponse = APIrequest.send();
			
		} catch (Exception j) {

		}
		return APIresponse;

	}

}
