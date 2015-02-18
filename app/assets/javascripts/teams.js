$(document).ready(function(){
  var another = $('#addplayers').clone();
  $('#datatableTeams').dataTable({
  	"iDisplayLength": 25,
  	"aaSorting": [[ 0, "desc" ]]
	});

  if (typeof $.prototype.select2 === "function") {
    $("select.addplayer").select2();
  }

	$(document).on('change', '.addplayer', function() {

    // Only add another if it was the last one in the list - don't count the hidden field above this el
    if ($(this).closest(".form-group").index() == $("#add_players_form .form-group").length) {
      another.clone().removeAttr('id').insertBefore($("#add_players_form button"));
      $("select.addplayer").select2();
    }
	});
	$('.fa-question-circle').popover();
	$('.fa-question-circle').on('shown.bs.popover', function(){
		setTimeout(function(){
			$('.fa-question-circle').popover('hide');
		}, 2500);
	})
});