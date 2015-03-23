function addtypeahead (){

}
$(document).ready(function(){
  var another = $('#addplayers').clone();
  $('#datatableTeams').dataTable({
  	"iDisplayLength": 25,
  	"aaSorting": [[ 0, "desc" ]]
	});

  $(document).on('change', '.addplayer', function() {

    // Only add another if it was the last one in the list - don't count the hidden field above this el
    if ($(this).closest(".form-group").index() == $("#add_players_form .form-group").length) {
      another.clone().removeAttr('id').insertBefore($("#add_players_form button"));      
    }
	});
	$('.fa-question-circle').popover();
	$('.fa-question-circle').on('shown.bs.popover', function(){
		setTimeout(function(){
			$('.fa-question-circle').popover('hide');
		}, 2500);
	})
  //Worth noting that with typeahead it's not triggering the above clone.  This currently only allows for the addition of one player at a time.
  $('.typeahead').typeahead({
    highlight: true,
    minLength: 3
    },
    {
      displayKey: 'name',
      source: function (query, process) {
        var map = {};
        var objects = [];
        $.get('/search/typeahead', { query: query }, function (data) {
          $.each(data, function(i, object){
            map[object.name] = object;
            objects.push({"name": object.name});
          });
          process(objects)
        });
      },
      updater: function(item){
       $('.typeahead').val(map[item].id);
       return item; 
      }
  });
});