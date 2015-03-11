$('input.filter').on('keyup', function() {
    var rex = new RegExp($(this).val(), 'i');
    $('.searchable tr').hide();
    $('.searchable tr').filter(function() {
        return rex.test($(this).text());
    }).show();
});
$(document).ready(function(){
	$('#admin-data-table').dataTable({
    "bPaginate": true,
    "iDisplayLength": 25,
    "aaSorting": [[ 1, "desc" ]]
  });

  // CSS and so on support for seeding tournaments
  $("#playoff_setup #size").on('change', function() {
    $(".list-dimming").removeClass("list-dimming-2 list-dimming-4 list-dimming-8 list-dimming-16 list-dimming-32 list-dimming-64 list-dimming-128");
    $(".list-dimming").addClass("list-dimming-" + $(this).val());
  });
  // Assign the seed values to the inputs
  $("#playoff_setup").on('submit', function() {
    $(this).find("li input").each(function() {
      $(this).val($(this).closest("li").index());
    });
  });

  $(".js-update-rules").on("click", ".btn", function(e) {
    var seasonId = $(e.delegateTarget).find("select").val();
    if (seasonId) {
      $.get("/seasons/" + seasonId + ".json", {}, function(data, status) {
        if (data.rules) {
          $('#season_rules').code(data.rules);
        }
      });
    }
  });
});