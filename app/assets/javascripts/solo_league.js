
$(document).ready(function(){
	$('.home_wins').click(function(){
		var home_wins = $(this).is(":checked");
		var season_id = $(this).attr('season');
		var match_id = $(this).attr("match");
		console.log(home_wins);
		console.log(season_id);
		$.post('/solo_leagues_json/update_score', {home_wins:home_wins, season_id:season_id, match_id:match_id});
	});
})