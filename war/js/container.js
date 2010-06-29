	
	var map;
	var eventArray = new Array();	
	var eventDescription = $('#mn_eventDescription');	
	var events;
	var current_page = 1;
	var events_per_page = 5;

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

	//creates new google map
	function create_map(){
		map = new google.maps.Map(document.getElementById("map_canvas"), {
      			zoom: 20,
      			center: new google.maps.LatLng(0,0),
      			mapTypeId: google.maps.MapTypeId.ROADMAP
    		});
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
		for (var i = 0; i < eventArray.length; i++){
			
			if (i < (array_start + events_per_page) && i > (array_start - 1)){
				add_event(eventArray[i]);
				eventArray[i].marker.setVisible(true);	
			} else {
				eventArray[i].marker.setVisible(false);
			}
					
		}
		
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
		var bounds = new google.maps.LatLngBounds();

		var eventlist = $('#map_canvasContainerLeft');
		var events = $('#mn_geoListContext');
		events.empty();

		//create map
		create_map();

		//clear events
		events.empty();
		$.each(data.results, function(i, ev) {
			if (ev.lon != ''){
				
				random_offset = (2*Math.random() - 1)/1000;
				random_offset2 = (2*Math.random() - 1)/1000;

				//create new point for each event and extend map bounds to include it
				point = new google.maps.LatLng(parseFloat(ev.lat) + random_offset, parseFloat(ev.lon) + random_offset2);
				bounds.extend(point);

				//create marker for point
				var marker = new google.maps.Marker({ 
					position: point,
					map: map,
					title: ev.container.name, 
				});

				//epoc time to date string
				var date = new Date(ev.time);
				var date_string = date.getMonth() + "/" + date.getDate() + "/" + date.getFullYear() + " " + date.getHours() + ":";
				if (date.getMinutes() < 10) {
					date_string = date_string + "0" + date.getMinutes();
				} else{
					date_string = date_string + date.getMinutes();
				}		

				//add event to list
				eventlist.append('<a href="/Event?' + ev.id + '">' + ev.title + '</a><br>');

				//provide link for each point with event info
				google.maps.event.addListener(marker, 'click', function() {
					
					var link = '<b><a href="' + ev.meetup_url + '" style="color:Blue">' + ev.container.name + '</a></b><br>WHERE: ' + ev.venue_name + '<br>WHEN: ' + date_string + '<br>';
						
					var win = new google.maps.InfoWindow({
						content: link,
					});
						win.open(map, marker);
				});

				//create event object
				event_object = new Object;

				event_object.ev = ev;			
				event_object.date = date_string;
				event_object.marker = marker;
				//add_event(event_object);
	
				//push object onto array
				eventArray.push(event_object);	

map.fitBounds(bounds);					
			}
		});
		update_events(current_page);	
		

		//fit map and set loc to adress


	}

