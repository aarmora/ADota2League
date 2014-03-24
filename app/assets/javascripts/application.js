// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//


//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require best_in_place

function IsEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

$(document).ready(function() {
    /* Activating Best In Place */
    jQuery(".best_in_place").best_in_place();

    // Handle the live games slide out. Size it on page load, and add the click handler
    var pulloutZeroOffset =  $("#LiveGames").outerHeight() - $("#LiveGames-Callout").outerHeight();

    $("#LiveGames").css("top", pulloutZeroOffset * -1);

    $("#LiveGames-Callout").on('click', function() {
        if ($("#LiveGames").css("top") == "0px") {
            $("#LiveGames").css("top", pulloutZeroOffset * -1);
        } else {
            $("#LiveGames").css("top", 0);
        }
    });
});


//tabs js
$(document).on('click', '#tabs .nonactive[id^="tab"]', function(){
    var tabname = $(this).attr('id').replace('tab', '');
    $(this).closest('#tabs').find('.active[id^="tab"]').removeClass('active').addClass('nonactive');
    $(this).removeClass('nonactive').addClass('active');
    $(this).closest('#tabs').find('.TabsContainer [class^="tabbody"]').removeClass('active').addClass('nonactive');
    $(this).closest('#tabs').find('.TabsContainer [class*="tabbody'+tabname+'"]').removeClass('nonactive').addClass('active');
});