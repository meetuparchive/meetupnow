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
@Searchable(root = true)
public class Topic {
    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Key key;

    @Persistent
    private String author;

    @Persistent
    @SearchableProperty
    private String name;

    @Persistent
    @SearchableId
    private int id;

    @Persistent
    private ArrayList<String> KeyWords;


    @Persistent
    @SearchableProperty
    private String KeyWordString;

    @Persistent
    @SearchableProperty
    private String Description;

    //constructors
    public Topic() {
	this.author = null;
	this.name = null;
	this.id = 0;
	KeyWords = new ArrayList<String>();
    }  

    public Topic(String desc, String author, String name, int id) {
        this.author = author;
        this.name = name;
        this.id = id;
	this.Description = desc;
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

    public String [] GetKeyWordArray(){
	return (String []) KeyWords.toArray();
    }

    public String GetKeyWordString(){
	return KeyWordString;
    }

    public String getDescription(){
	return Description;
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

    public void setKeyWords(String words){
	this.KeyWordString = words;
    }

    public void addKeyWord(String word){
	this.KeyWords.add(word);
	this.KeyWordString.concat(word + " ");
    }

    public void setDescription(String desc){
	this.Description = desc;
    }

    public String getDescriptionSubstring(int maxlength) {
	if (Description.length() > maxlength) {
		String out = Description.substring(0,maxlength);
		out = out.concat("...");
		return out;
	} else {
		return Description;
	}
    }
}
