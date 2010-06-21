package meetupnow;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;

import java.util.Date;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable
public class Topic {
    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Key key;

    @Persistent
    private String author;

    @Persistent
    private String name;

    @Persistent
    private int id;

    public Topic() {
	this.author = null;
	this.name = null;
	this.id = 0;
    }  

    public Topic(String author, String name, int id) {
        this.author = author;
        this.name = name;
        this.id = id;
    }

    public Key getKey() {
        return key;
    }

    public String getAuthor() {
        return author;
    }

    public String getName() {
        return name;
    }

    public int getId() {
        return id;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setId(int id) {
        this.id = id;
    }
}
