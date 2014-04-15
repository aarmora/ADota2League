$(document).ready(function(){
  var another = $('#addplayers').clone();
  $("select.addplayer").select2();

	$(document).on('change', '.addplayer', function() {

    // Only add another if it was the last one in the list
    if ($(this).closest(".form-group").index() == $("#add_players_form .form-group").length - 1) {
      another.clone().removeAttr('id').insertBefore($("#add_players_form .button"));
      $("select.addplayer").select2();
    }
	});
});