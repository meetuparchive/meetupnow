package meetupnow;

import com.google.appengine.api.datastore.Key;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import java.util.StringTokenizer;

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

	@Persistent
	private String zip;

	@Persistent
	private String distance;

	@Persistent
	private String cellNum;

	@Persistent
	private String carrier;

	@Persistent
	private boolean cellOpt;
	
	@Persistent
	private boolean emailOpt;

	public UserInfo() {
		zip = "";
		user_id = "";
		groups = "";
		loginCount = 0;
		email = "";
		distance = "";
		cellNum = "";
		carrier = "";
		cellOpt = false;
		emailOpt = false;
	}

	public Key getKey() {
		return key;
	}

	public void setZip(String z) {
		zip = z;
	}

	public String getZip() {
		return zip;
	}

	public boolean getCellOpt() {
		return cellOpt;
	}
	
	public boolean getEmailOpt() {
		return emailOpt;
	}

	public void setCellOpt(boolean b) {
		cellOpt = b;
	}
	
	public void setEmailOpt(boolean b) {
		emailOpt = b;
	}

	public void setCellNum(String c) {
		cellNum = c;
	}
	
	public String getCellNum() {
		return cellNum;
	}

	public void setCarrier(String c) {
		carrier = c;
	}

	public String getCarrier() {
		return carrier;
	}

	public void setDistance(String d) {
		distance = d;
	}

	public String getDistance() {
		return distance;
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

	//Add group if not already a member
	public void addGroup(String g) {
		StringTokenizer st = new StringTokenizer(groups,",");
		while (st.hasMoreTokens()) {
			if (st.nextToken().equals(g)) {
				return;
			}
		}
		String temp = groups.concat(g+",");
		groups = temp;
	}

	public void removeGroup(String g) {
		StringTokenizer st = new StringTokenizer(groups,",");
		String output = "";
		while (st.hasMoreTokens()) {
			String temp = st.nextToken();
			if (!temp.equals(g)) {
				output = output.concat(temp+",");
			}
		}
		
		groups = output;
	}

	public String[] getGroupArray() {
		StringTokenizer st = new StringTokenizer(groups,",");
		String[] output = new String[st.countTokens()];
		int i = 0;
		while (st.hasMoreTokens()) {
			output[i] = st.nextToken();
			i++;
		}
		return output;
	}

	public boolean isMember(String c_id) {
		if (c_id != null) {
			StringTokenizer st = new StringTokenizer(groups,",");
			while (st.hasMoreTokens()) {
				if (st.nextToken().equals(c_id)) {
					return true;
				}
			}
			return false;
		}
		else return false;
	}
}
