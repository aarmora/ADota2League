$(document).ready(function(){

  // Setup the week seletor to show the table for each week
  $(".week-selector").on("click", "a", function(e, data) {
    $(".week-selector a").removeClass("active");
    e.preventDefault();
    $(this).addClass("active");
    $(".week-holder").hide();
    $("#week_" + $(this).data("week")).show();
  });
});