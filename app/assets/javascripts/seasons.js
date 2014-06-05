$(document).ready(function(){

  // Setup the week seletor to show the table for each week
  $(".week-selector").on("click", "a", function(e, data) {
    $(".week-selector a").removeClass("active");
    e.preventDefault();
    $(this).addClass("active");
    $(".week-holder").hide();
    $("#week_" + $(this).data("week")).show();
  });

  // Check in button
  $(".js-check-in").on("click", function(e, data) {
    $.ajax({
      type: "POST",
      url: $(this).data("url") + ".json",
      data: {
        "_method": "put",
        "team_season[checked_in]": true
      },
      success: function() {
        $(this).replaceWith("Yes");
      }.bind(this)
    });
  });
});