$(document).ready(function(){
	$("form").bind('ajax:complete', function(data){
		//This is a hack.  Not sure of a better way to do it.
		$.get('/matchcommentspartial', {match_id:$('#matchcomment_match_id').val()}, function(data){
			$('#matchcommentspartial').html(data);
		});	
	});
})