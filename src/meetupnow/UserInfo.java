package meetupnow;

import com.google.appengine.api.datastore.Key;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable
public class UserInfo {
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	@Persistent
	private String mu_id;

	@Persistent
	private String prefs;	//Preferences in string form

	public UserInfo() {
		mu_id = "";
		prefs = "";
	}

	public Key getKey() {
		return key;
	}

	public String getID() {
		return mu_id;
	}

	public String getPrefs() {
		return prefs;
	}

	public void setID(String id) {
		mu_id = id;
	}

	public void setPrefs(String p) {
		prefs = p;
	}

	public void addPref(String p) {
		String temp = prefs.concat(p+",");
		prefs = temp;
	}
}
