package meetupnow;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;

import java.util.Date;
import java.util.ArrayList;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;


@PersistenceCapable
public class Suggestion {
    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Key key;

    @Persistent
    private String subject;

    @Persistent
    private String content;

    @Persistent
    private String address;

    //constructors
    public Suggestion() {
	subject = null;
	content = null;
	address = null;
    }  
    public Key getKey() {
        return key;
    }

	public String getSubject() {
		return subject;
	}

	public String getContent() {
		return content;
	}
	
	public String getAddress() {
		return address;
	}

	public void setSubject(String s) {
		subject = s;
	}

	public void setContent(String c) {
		content = c;
	}

	public void setAddress(String a) {
		address = a;
	}

}
