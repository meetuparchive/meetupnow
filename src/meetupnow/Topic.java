package meetupnow;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;

import java.util.Date;
import java.util.ArrayList;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import org.compass.annotations.*;


@PersistenceCapable
@Searchable(root = false)
@SearchableConstant(name = "type", values = {"person", "author"})
public class Topic {
    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Key key;

    @Persistent
    private String author;

    @Persistent
    @SearchableProperty(name = "name")
    @SearchableMetaData(name = "authorName")

    private String name;

    @Persistent
    private int id;

    @Persistent
    private ArrayList<String> KeyWords;


    @Persistent
    @SearchableProperty
    private String KeyWordString;

    //constructors
    public Topic() {
	this.author = null;
	this.name = null;
	this.id = 0;
	KeyWords = new ArrayList<String>();
    }  

    public Topic(String author, String name, int id) {
        this.author = author;
        this.name = name;
        this.id = id;
	KeyWords = new ArrayList<String>();
    }

    //geters
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

    public String [] GetKeyWords(){
	return (String []) KeyWords.toArray();
    }


    //seters
    public void setAuthor(String author) {
        this.author = author;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void addKeyWord(String word){
	this.KeyWords.add(word);
	this.KeyWordString.concat(word + " ");
    }
}
