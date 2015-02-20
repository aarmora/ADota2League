function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

$(document).ready(function(){
	// When they select a team, load the season select partial
	$('#teamPicker').change(function(){
		$.get('/reg_form_partial', {player_id:$(this).attr("playerId"), team_id:$(this).val()}, function(data){
			$('#regFormHolder').html(data);
		});
	});

	// When they create the new team, fetch the match partial immediately after.
	$('#new_team').on('ajax:success', function(e, data, status, xhr) {
		$('#regFormHolder').html("<h3>Loading available seasons...</h3>");
		$.get('/reg_form_partial', {team_id: data.id}, function(data) {
			$('#regFormHolder').html(data);
		});
	});

	$('#new_team').on('ajax:error' , function(e, data, status, xhr) {
		alert("Sorry, there was an error creating your team. Please try again later!");
	});
	if(getParameterByName("refid")){
		ga('send', 'event', 'our_ads', 'click', getParameterByName("refid"));
	}
});