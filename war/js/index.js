	
	var map;
	var eventArray = new Array();	
	var eventDescription = $('#mn_eventDescription');	
	var events;
	var current_page = 1;
	var events_per_page = 5;
	var d = new Date();


	//event sorting functions
	function SortByRSVP(a, b){
		alert(a.ev.rsvp_count);
		if (a.ev.rsvp_count < b.ev.rsvp_count) {
			return 1;
		} else {
			return -1;
		}
	}

	function SortByTime(a, b){
		//alert((a.ev.time - d.getTime()) > (b.ev.time - d.getTime()));
		if  ((a.ev.time - d.getTime()) > (b.ev.time - d.getTime())){
			return 1;
		} else {
			return -1;		
		}
	}

	function SortByDistance(a, b){

	}

	//set description to any string
	function changeDiscription(desc){
		var eventDescription = $('#mn_eventDescription');
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
						changeDiscription(eventArray[i].ev.description + '<br><br><a href="/Event?' + eventArray[i].ev.id + '"> Event Page </a><br><a href="/Group?' + eventArray[i].ev.container.id + '"> Topic Page </a>');

					
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
      			zoom: 15,
      			center: new google.maps.LatLng(0,0),
      			mapTypeId: google.maps.MapTypeId.ROADMAP
    		});
	}

	//add event to list under map
	function add_event(event){
		var title;
		if (event.ev.title) {
			title = event.ev.title;
			if (title.length > 30) {
				title = title.substring(0,30) + "...";
			}
		}
		else {
			title = "Event #"+event.ev.id;
		}
		var loc;
		if (event.ev.state) {
			loc = event.ev.city + ", " + event.ev.state;
		}
		else {
			loc = event.ev.city + ", " + event.ev.country;
		}
		events.append('<span class="mn_geoListItem" onMouseOver="javascript:event_show(' + event.ev.id + ')" onMouseOut="javascript:event_show(-1)"><span class="when"><span class="mn_geoListItem_date"> ' + event.date + ' </span><!-- end .mn_geoListItem_date --><span class="mn_geoListItem_time"> ' + event.time + ' </span><!-- end .mn_geoListItem_time --></span> <!-- end .when --><span class="details"><span class="mn_geoListItem_title"><a href="/Event?' + event.ev.id + '"> ' + title + ' </a></span><!-- end .mn_geoListItem_title --><span class="mn_geoListItem_topic"><a href="/Topic?' + event.ev.container.id + '" title="'+ event.ev.container.name +'">'+event.ev.container.name+'</a></span><span class="loc"><span class="city"> ' + loc + ' </span><!-- end .city --></span><!-- end .loc --></span><!-- end .details --></span>');

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
		
		$('.pageinationNav').empty();

		//Next page / previous page link (when applicable)
		if (((current_page) * events_per_page) >= eventArray.length){

			$('.paginationNav').html('<a href="javascript:prevPage()"><span class="prevPage">&laquo; PREVIOUS</span></a>');
		}
		else if (current_page <= 1){

			$('.paginationNav').html('<a href="javascript:nextPage()"><span class="nextPage">NEXT &raquo;</span></a>');
		}
		else{

			$('.paginationNav').html('<a href="javascript:prevPage()"><span class="prevPage">&laquo; PREVIOUS</span></a><a href="javascript:nextPage()"><span class="nextPage">NEXT &raquo;</span></a>');
		}		

		//add a show all option to list of events
		//$('.showAll').html('<a href="javascript:event_show(-1)">Show All</a>');
	}

	//populates map and list with events
	function use_everywhere(data){
		var event_object;
		var bounds = new google.maps.LatLngBounds();

		events = $('#mn_geoListBody');

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
				var date_string = getDay(date.getDay())+", "+getMonth(date.getMonth()) + " " + date.getDate();
				var time_string = getTime(date.getHours(),date.getMinutes(),0);

				//add event to list
				

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
				event_object.time = time_string;
				event_object.marker = marker;
				//add_event(event_object);
	
				//push object onto array
				eventArray.push(event_object);						
			}
		});
		eventArray.sort(SortByRSVP);
		update_events(current_page);	
		

		//fit map and set loc to adress
		map.fitBounds(bounds);

	}

function getMonth(m) {
	switch (m)
	{
	case 0:
  		return ("Jan");
	case 1:
		return ("Feb");		
	case 2:
  		return ("Mar");
	case 3:
		return ("Apr");
	case 4:
		return ("May");
	case 5:
		return ("Jun");
	case 6:
		return ("Jul");
	case 7:
		return ("Aug");
	case 8:
		return ("Sep");
	case 9:
		return ("Oct");
	case 10:
		return ("Nov");
	case 11:
		return ("Dec");
	default:
		return ("Undef");
	}
}

function getDay(d) {
	switch (d)
	{
	case 0:
  		return ("Sun");
	case 1:
		return ("Mon");
	case 2:
		return ("Tue");
	case 3:
		return ("Wed");
	case 4:
		return ("Thu");
	case 5:
		return ("Fri");
	case 6:
		return ("Sat");
	default:
		return ("NaN");	
	}
}

function getTime(h, m, timezone) {
	h = (h+timezone);
	h %= 24;
	if (h==0) {h=24;}
	var time = "AM";

	if (h >= 12) {time = "PM";}
	if (h > 12) { h = h - 12;}
	if (m > 9) { return (h + ":" + m + " " + time);}
	else {return (h + ":0" + m + " " + time);}
}

// Get $_GET[param] JS
function getParameterByName( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

// Close modal dialogue if get[reload]=1
// var paramValue = "";
// 
// if (paramValue = getParameterByName('reload'))
// {
// 	if (paramValue == 1)
// 	{
// 		$('#modal_login').hide();
// 		$('#mask').hide();
// 		window.location.reload();
// 	}
// }

