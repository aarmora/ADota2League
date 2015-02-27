$(document).ready(function(){

  // Setup the week seletor to show the table for each week
  $(".week-selector").on("click", "a", function(e, data) {
    $(".week-selector a").removeClass("active");
    e.preventDefault();
    $(this).addClass("active");
    $(".week-holder").hide();
    $("#week_" + $(this).data("week")).show();
  });

  // Find all times on the page (might be cached), and convert to local TZ
  $(".week-holder .js-time").each(function() {
      var epoch = $(this).data("epoch-offset");
      var timeString = moment(epoch * 1000).tz(USER_TZ).format("M/D/YY h:mmA z");
      $(this).replaceWith(timeString);
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

  // Tournament bracket behavior
  $(".Bracket .game").hover(
    // mousein
    function(e) {
      var teamId = $(this).data("participant-id");
      console.log("hovering: " + teamId );
      if (teamId) {
        $(".Bracket .game[data-participant-id=" + teamId + "]").addClass("active");
      }
    },
    // mouse out
    function(e) {
      $(".Bracket .game").removeClass("active");
    }
  );
});