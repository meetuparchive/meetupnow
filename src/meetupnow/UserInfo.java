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
	private String user_id;

	@Persistent
	private String groups;	//Preferences in string form

	@Persistent
	private int loginCount;

	@Persistent
	private String email;

	public UserInfo() {
		user_id = "";
		groups = "";
		loginCount = 0;
		email = "";
	}

	public Key getKey() {
		return key;
	}

	public void setEmail(String e) {
		email = e;
	}

	public String getEmail() {
		return email;
	}

	public int getLoginCount() {
		return loginCount;
	}

	public void incrementLoginCount() {
		loginCount++;
	} 

	public String getID() {
		return user_id;
	}

	public String getGroups() {
		return groups;
	}

	public void setID(String id) {
		user_id = id;
	}

	public void setGroups(String g) {
		groups = g;
	}

	public void addGroup(String g) {
		String temp = groups.concat(g+",");
		groups = temp;
	}
}
