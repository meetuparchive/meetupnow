

$(document).ready(function() {
	
	// Hide comment form initially
	$('#commentInputContext').hide();
	
	$('a[name=commentToggle]').click(function(e) {
		
		// Cancel default link behavior
		e.preventDefault();
		
		// Get the anchor tag
		var id = $(this).attr('href');
		
		// Change label
		//$(this).text($(this).text() == 'Add a Comment' ? 'Cancel' : 'Add a Comment');
		if ($(this).text() == 'Add a Comment')
		{
			$(this).text('Cancel');
		}
		else if ($(this).text() == 'Cancel')
		{
			$(this).text('Add a Comment');
			$('textarea[name=comment]').val('');
		}
		
		
		
		$(id).slideToggle('fast', function() {
			// Animation complete
		});
	});
});