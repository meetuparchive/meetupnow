	

	var eventArray = new Array();	
	var eventDescription = $('#mn_eventDescription');	
	var events;
	var current_page = 1;
	var events_per_page = 5;
	var evt;
	var JSONList = {
  'wiki-url':"http://simile.mit.edu/shelf/", 
  'wiki-section':"Simile JFK Timeline", 
  'dateTimeFormat': 'Gregorian',
  'events' : [] };

	var EventSource = new Timeline.DefaultEventSource();
 	var tl;
 	function onLoad() {
      		var dateEvent = new Date();
             	var eventSource = new Timeline.DefaultEventSource(); 
   		var bandInfos = [
     			Timeline.createBandInfo({
         			width:          "70%", 
         			intervalUnit:   Timeline.DateTime.HOUR, 
         			intervalPixels: 100,
              			eventSource: eventSource
	
			}),
     			Timeline.createBandInfo({
         			width:          "30%", 
         			intervalUnit:   Timeline.DateTime.DAY, 
         			intervalPixels: 300,
				eventSource: eventSource
			})
   		];
		

   		bandInfos[1].syncWith = 0;
   		bandInfos[1].highlight = true;

		tl = Timeline.create(document.getElementById("map_canvas"), bandInfos);
      		eventSource.loadJSON(JSONList, '');


 }
 
 var resizeTimerID = null;
 function onResize() {
     if (resizeTimerID == null) {
         resizeTimerID = window.setTimeout(function() {
             resizeTimerID = null;
             tl.layout();
         }, 500);
     }
 }





	//set description to any string
	function changeDiscription(desc){
		eventDescription = $('#mn_eventDescription');
		eventDescription.empty();
		eventDescription.append(desc);	
	}

	//shows only one event on map and gives its descriptions and links on the side
	//if event_id = -1 then shows all and no description or links
	function event_show(event_id){
		changeDiscription("");
		var array_start = (current_page - 1)*events_per_page;
		for (var i = 0; i < eventArray.length; i++){
			if (i < (array_start + events_per_page) && i > (array_start - 1)){
				if (event_id == -1) {
					eventArray[i].marker.setVisible(true);
				}
				else{
					if (eventArray[i].ev.id == event_id){
						eventArray[i].marker.setVisible(true);
						changeDiscription(eventArray[i].ev.description + '<br><br><a href="/Event?' + eventArray[i].ev.id + '"> Event Page </a><br>');

					
					} else {
						eventArray[i].marker.setVisible(false);
					}
				}
			} else {
				eventArray[i].marker.setVisible(false);			
			}
			
		}

	}

	//add event to list under map
	function add_event(event){
		events.append('<a href="javascript:event_show(' + event.ev.id + ')" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> ' + event.date + ' </span><span class="mn_geoListItem_where"> ' + event.ev.city + ' </span><span class="mn_geoListItem_title"> ' + event.ev.container.name + ' <br> ' + event.ev.rsvp_count + ' people are in </span>');
		if (event.ev.attending == "yes"){
			events.append('<span class="mn_geoListItem_rsvpButton">You\'re In!</span>');
		} else {
			events.append('<span class="mn_geoListItem_rsvpButton"><a href="/EventRegister?cid='+ event.ev.container.id +'&id=' + event.ev.id + '&callback=ContainerPage2.jsp?' + event.ev.container.id + '">I\'m In</a></span>');
		}
		events.append('</span></a>');
	}

	//go to next page if it exists
	function nextPage(){

		if ((current_page * events_per_page) < eventArray.length){
			current_page++;
			event_show("");
			update_events();
		} 
	}

	//go back a page if it exists
	function prevPage(){

		if (current_page > 1){
			current_page--;
			event_show("");
			update_events();
		}
	}

	//updates events to a number of events on a certain page
	function update_events(){
		var array_start = (current_page - 1)*events_per_page;
		
		events.empty();
	
		
		//Next page / previous page link (when applicable)
		if ((current_page * events_per_page) < eventArray.length){
			events.append('<a href="javascript:nextPage()" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> next Page </span><span class="mn_geoListItem_where">  </span><span class="mn_geoListItem_title">  </span></span></a>');
		}

		if (current_page > 1){
			events.append('<a href="javascript:prevPage()" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> Previous Page </span><span class="mn_geoListItem_where">  </span><span class="mn_geoListItem_title">  </span></span></a>');
		}

		//add a show all option to list of events
		events.append('<a href="javascript:event_show(-1)" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> Show All </span><span class="mn_geoListItem_where">  </span><span class="mn_geoListItem_title">  </span></span></a>');
	}

	//populates map and list with events
	function use_everywhere(data){
		var event_object;


		var eventlist = $('#activity');
		var events = $('#mn_geoListContext');
		events.empty();

	

		//clear events
		events.empty();
		$.each(data.results, function(i, ev) {
			if (ev.lon != ''){
						

				//epoc time to date string
				var date = new Date(ev.time);
				var today = new Date();
				
				if (date.getDate() == today.getDate()) {
					ttText = "Today @ ";
				}
				else if (date.getDate() == today.getDate()+1) {
					ttText = "Tomorrow @ ";
				}
				
				if (date.getHours() > 11) {
					ampm = " PM";
				} else {
					ampm = " AM";
				}
				
				if (date.getHours() > 12) {
					chour = date.getHours() - 12;
				} else {
					chour = date.getHours()
				}
				
				var date_string = date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear() + " " + chour + ":";
				
				
				
				
				if (date.getMinutes() < 10) {
					date_string = date_string + "0" + date.getMinutes() + ampm;
					time_string = ttText + chour + ":0" + date.getMinutes() + ampm;
				} else{
					date_string = date_string + date.getMinutes() + ampm;
					time_string = ttText + chour + ":" + date.getMinutes() + ampm;
				}		

				JSONList.events.push( { 'start' : date , 'title' : ev.title } );
				
				if (ev.rsvp_count > 1) {
					c_rsvpCount = "<span class='statNum'>" + ev.rsvp_count + "</span> RSVPs";
				} else {
					c_rsvpCount = "New Event!";
				}

				//add event to list
				eventlist.append('<div class="commentFeedItem"><div class="line"><div class="unit size3of5"><span class="tsItem_title"><a href="/Event?' + ev.id + '">' + ev.title + '</a></span><span class="tsItem_desc">' + ev.description + '</span></div><!--end .unit .size3of5--><div class="unit size1of5"><span class="statsBody">' + c_rsvpCount + '</span></div><!--end .unit .size1of5--><div class="unit size1of5 lastUnit">' + time_string + '<br/>' + ev.city + ', ' + ev.state + '</div><!--end .unit .size1of5 .lastUnit--></div><!--end .line--></div><!--end .commentFeedItem-->');

			

				//create event object
				event_object = new Object;

				event_object.ev = ev;			
				event_object.date = date_string;

				//add_event(event_object);
	
				//push object onto array
				eventArray.push(event_object);	


			}
		});
onLoad();

		update_events(current_page);	
		


	}

