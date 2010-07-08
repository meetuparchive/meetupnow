<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.Date" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.List" %>
<%@ page import="meetupnow.MeetupUser" %>
<%@ page import="meetupnow.PMF" %>
<%@ page import="org.scribe.oauth.*" %>
<%@ page import="org.scribe.http.*" %>
<%


String key = "empty";
javax.servlet.http.Cookie[] cookies = request.getCookies();

	
if (cookies != null) {
	for (int i = 0; i < cookies.length; i++) {
		if (cookies[i].getName().equals("meetup_access")) {
			key = cookies[i].getValue();
		}
	}
}
if (key.equals("empty")) {
	response.sendRedirect("/oauth");
}

int loopnum = 1;
try {
	loopnum = Integer.parseInt(request.getQueryString());
} catch (Exception e) {}

//ADDRESS GEN
String ad = "";
String[] zips = {"06612","06825","02675","10012","10011","22222","30303","07410","70112","60601","99501","90210","23432"};

//EVENT GEN

String[] ids = {"946","943","947","944","945","949","948","936","942","941"};
String[][] venues = {
	{"Habitat For Humanity","Homeless Shelter","Soup Kitchen"},
	{"Burger King","Olive Garden"},
	{"GameStop","Comic Store"},
	{"Mountain Peak","The Track"},
	{"Jamba Juice","Taco Bell"},
	{"Greg's House","Mary's House"},
	{"The Old Bridge", "Museum of History"},
	{"Football Field", "Basketball Court"},
	{"The Library", "Room 45a"},
	{"Showtime Cinemas","My Basement"}
};
String[][] descs = {
	{"Let's be good samaritans and help people out for a change!\nAll you need to spare is a little bit of time","Be nice to other people! Giving back is good! Meet up around the flag pole and we will split up into teams to go make a difference in people's lives.","Lets make a difference"},
	{"I am so freaking hungry... And I hate eating alone.  I know I can't be the only hungry person around here, so lets get a group of interesting people together to share an interesting meal.","I own this restaurant and I would like to say that tonight and tonight only we are offering a 50% off special on all entrees. RSVP here to be eligible!","FEEEEEED MEEEEEEEEE"},
	{"Video game tournament here tonight, all skill levels welcome.  We will be playing Call Of Duty, Mario Kart, Super Smash Brothers, and Madden 2011. So come prepared!\n Entrance fee is $5.","Lets all sit around and play WoW tonight! I keep thinking I should be more social, but i don't want to give up WoW, so this is the perfect combination.  I have a bunch of computers set up already, so come on down!","I need people to game with!"},
	{"There is nothing better than good old exercise.  With that said, there is something better, and that is group exercizing!  Meet up at the beginning of the track and we will see how far we can go. no stragglers!!  I'll be wearing a blue shirt and grey shorts","I'm going to be running the distance this morning... if you want to join feel free.","Looking for workout buddies!"},
	{"I had a great idea the other day, lets get a bunch of random people together, and then write and perform a play on the sidewalk!! Someone bring a video camera, i'll be here with paper and pens to write the script. See you there :)","I feel like doing arts and crafts today, I have a bunch of supplies so if you want to come and be creative together, i'll be at a table tonight. See you there!","Lets do something completely bat-shit insane"},
	{"We're having a kegger tonight at Delta Alpha Pi, so come by and get wasted tonight!  $5 per head to cover brews, and PLEASE PLEASE PLEASE carpool. 21 and up only, we WILL be checking.","I'm having a Harry Potter themed party at my house tonight, so come dressed up as harry, ron, hermione, or your favorite other character.  NO MUGGLES ALLOWED :)","PAAAARRTTTTTTYYYYYYYYYYY"},
	{"Hey, I'm new in town and kinda want to see whats up here.  If your new too and want to join, or you're a native and feel like showing us around, join up!", "I'm leading a trip to this historical site later, and wouldn't mind bringing along a few more. If you are interested, sign up!!","I like museums. A Lot"},
	{"We're trying to get a pickup game going later, (we already have 5, but the more the merrier), so bring your skills to the field later and we'll see what you got! (PS we arent that good, so don't be afraid)", "Trying to get a game together... Im feeling aggressive and am in the mood for some good old fashioned team sports.  I'm open to suggestions, but lets meet up and get something going!","I need to play some sports, Right NOW"},
	{"Soooo I have a HUGE test in two days, and I need some major help.  Lets get a big study group together so we can all help each other out with our respective strengths and weaknesses! Strength in numbers! God i'm stressed.", "I'm hosting a math tutorial later, i'll be covering calc trig and geometry so if you need any help in any of those subjects come on by!","If anyone else is studying at the library, thats where i'll be too!!"},
	{"There is a twilight zone marathon on tonight! Who wants to get some popcorn and watch for 12 straight hours? I DO!!!!!!!! ","Lets all go to see the new Star Trek movie dressed in starfleet uniforms. I have a bunch so anyone who wants to borrow one lmk","Lets watch stuff on TV... I'm tired of doing it on my own, i need some more people here!"}
};

String[][] names = {
	{"Helping People","Helping Hand","Doing Good Deeds", "Being a good samaritan","Awesome ways to feel good about yourself"},
	{"Lets get a meal","I'm Hungry", "Food anyone?", "STARRRVING","FOOD NOW"},
	{"Computer Game Tourny!","Computer party!", "Lets start a Horde!!","NEED MORE NERDS"},
	{"Running with Strangers","Exercise is good for you","Lets get buff","Climbing the hill","Work those glutes"},
	{"Great new idea!","Lets Try Something","Being Random","I LOVE STRANGERS!"},
	{"Awesome Party Tonight!","Party Alllll niiight Lonnnng","Freaking crazy party","This is where its at tonight"},
	{"New In Town", "See some sights!","Learn Something","Tour Group"},
	{"Football Game", "Basketball","Baseball Game","Bowling","Tennis","Soccer"},
	{"Study Group", "Team effort!", "I'm so screwed","Big test tomorrow!"},
	{"Movie Night!","Marathons!","Lots of room in my den"}
};



//DATE GEN
Date d = new Date();
int offset = (int)(Math.random()*48);
d.setHours(d.getHours()+offset);
String millitime = ""+d.getTime();

Properties prop = new Properties();
prop.setProperty("consumer.key","12345");
prop.setProperty("consumer.secret","67890");
Scribe scribe = new Scribe(prop);
PersistenceManager pm = PMF.get().getPersistenceManager();
Query query = pm.newQuery(MeetupUser.class);
query.setFilter("accToken == accTokenParam");
query.declareParameters("String accTokenParam");
String API_URL = "http://api.meetup.com/ew/event/";
try {
	List<MeetupUser> users = (List<MeetupUser>) query.execute(key);
	if (users.iterator().hasNext()) {
		Token accessToken = new Token(users.get(0).getAccToken(),users.get(0).getAccTokenSecret());
		Request APIrequest;
		Response APIresponse;
		int c_select;
		int v_select;
		int d_select;
		int n_select;
		int z_select;
		for (int i = 0; i < loopnum; i++) {

			c_select = (int)(Math.floor((Math.random()*ids.length)));
			v_select = (int)(Math.floor((Math.random()*venues[c_select].length)));
			d_select = (int)(Math.floor((Math.random()*descs[c_select].length)));
			n_select = (int)(Math.floor((Math.random()*names[c_select].length)));
			z_select = (int)(Math.floor((Math.random()*zips.length)));

			APIrequest = new Request(Request.Verb.POST, API_URL);
			APIrequest.addBodyParameter("venue_name",venues[c_select][v_select]);
			APIrequest.addBodyParameter("address1", ad);
			APIrequest.addBodyParameter("zip", zips[z_select]);
	
			APIrequest.addBodyParameter("time",millitime);
			APIrequest.addBodyParameter("container_id",ids[c_select]);
			APIrequest.addBodyParameter("description",descs[c_select][d_select]);
			APIrequest.addBodyParameter("title",names[c_select][n_select]);
			APIrequest.addBodyParameter("fields","title");
			APIrequest.addBodyParameter("organize","true");
				

			scribe.signRequest(APIrequest,accessToken);
			APIresponse = APIrequest.send();
		}
	}
} catch (Exception j){
			
}
finally {
	query.closeAll();
	pm.close();
}


%>
