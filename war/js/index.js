	
	var map;
	var eventArray = new Array();	
	var eventDescription = $('#mn_eventDescription');	


	//set description to any string
	function changeDiscription(desc){
		var eventDescription = $('#mn_eventDescription');
		eventDescription.empty();
		eventDescription.append(desc);	
	}

	//shows only one topic on map and gives its descriptions and links on the side
	//if event_id = -1 then shows all and no description or links
	function topic_show(event_id){
		changeDiscription("");
		for (var i = 0; i < eventArray.length; i++){
			if (event_id == -1) {
				eventArray[i].marker.setVisible(true);
			}
			else{
				if (eventArray[i].id == event_id){
					eventArray[i].marker.setVisible(true);
					changeDiscription(eventArray[i].description + '<br><br><a href="/Event?' + eventArray[i].id + '"> Event Page </a><br><a href="/Group?' + eventArray[i].cont_id + '"> Group Page </a>');

					
				} else {
					eventArray[i].marker.setVisible(false);
				}
			}
			
		}

	}

	//creates new google map
	function create_map(){
		map = new google.maps.Map(document.getElementById("map_canvas"), {
      			zoom: 15,
      			center: new google.maps.LatLng(0,0),
      			mapTypeId: google.maps.MapTypeId.ROADMAP
    		});
	}

	//populates map and list with events
	function use_everywhere(data){
		var event_object;
		var bounds = new google.maps.LatLngBounds();

		var events = $('#mn_geoListContext');

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

				//creat marker for point
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
				events.append('<a href="javascript:topic_show(' + ev.id + ')" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> ' + date_string + ' </span><span class="mn_geoListItem_where"> ' + ev.city + ' </span><span class="mn_geoListItem_title"> ' + ev.container.name + ' </span></span></a>');

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
				event_object.id = ev.id;
				event_object.description = ev.description;
				event_object.marker = marker;
				event_object.cont_id = ev.container.id;
	
				//push object onto array
				eventArray.push(event_object);						
			}
		});
	
		//add a show all option to list of events
		events.append('<a href="javascript:topic_show(-1)" class="mn_geoListItem_link"><span class="mn_geoListItem"><span class="mn_geoListItem_date"> Show All </span><span class="mn_geoListItem_where">  </span><span class="mn_geoListItem_title">  </span></span></a>');

		//fit map and set loc to adress
		map.fitBounds(bounds);

	}

