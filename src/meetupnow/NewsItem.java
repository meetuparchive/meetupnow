package meetupnow;

import com.google.appengine.api.datastore.Key;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import java.util.Date;

@PersistenceCapable
public class NewsItem {
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	//comment, event_create, event_rsvp, container_create, container_subscribe
	@Persistent
	private String type;

	@Persistent
	private String name;

	@Persistent
	private String message;

	@Persistent
	private long timeCreated;

	@Persistent
	private String link;

	@Persistent
	private String ev_con_name;	

	@Persistent
	private String container;

	public NewsItem() {
		Date d = new Date();
	
		link = "";
		type = "";
		name = "";
		message = "";
		ev_con_name = "";
		container = "";
		
		timeCreated = d.getTime();
	}

	public Key getKey() {
		return key;
	}
	
	public String getLink() {
		return link;
	}

	public void setLink(String l) {
		link = l;
	}

	public String getEvConName() {
		return ev_con_name;
	}

	public void setEvConName(String e) {
		ev_con_name = e;
	}

	public String getContainerName() {
		return container;
	}

	public void setContainerName(String e) {
		container = e;
	}

	public long getTimeCreated() {
		return timeCreated;
	}

	public String getName() {
		return name;
	}

	public String getType() {
		return type;
	}

	public String getMessage() {
		return message;
	}

	public void setName(String n) {
		name = n;
	}

	public void setType(String t) {
		type = t;
	}

	public void setMessage(String m) {
		message = m;
	}
	
	public void setTimeCreated(long t) {
		timeCreated = t;
	}
}
