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
//= require jquery.ui.datepicker
//= require twitter/bootstrap
//= require best_in_place
//= require best_in_place_datetime
//= require_tree .

function IsEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

$(document).ready(function() {
    /* Activating Best In Place */
    jQuery(".best_in_place").best_in_place();

    // Handle the live games slide out. Size it on page load, and add the click handler
    function pulloutZeroOffset() {
        return $("#LiveGames").outerHeight() - $("#LiveGames-Callout").outerHeight();
    }

    $("#LiveGames").css("top", pulloutZeroOffset() * -1);

    $("#LiveGames-Callout").on('click', function() {
        if ($("#LiveGames").css("top") == "0px") {
            $("#LiveGames").css("top", pulloutZeroOffset() * -1);
        } else {
            $("#LiveGames").css("top", 0);
        }
    });

    // handle the admin adaptive forms
    $("form.adaptive").on('submit', function() {
        var $el = $(this).find("[name=id]");
        if ($el) {
            $(this).attr("action", $(this).attr("action").replace("/id", "/" + $el.val()));
        }
    });
});
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-46030946-1', 'amateurdota2league.com');
ga('send', 'pageview');



//tabs js
$(document).on('click', '#tabs .nonactive[id^="tab"]', function(){
    var tabname = $(this).attr('id').replace('tab', '');
    $(this).closest('#tabs').find('.active[id^="tab"]').removeClass('active').addClass('nonactive');
    $(this).removeClass('nonactive').addClass('active');
    $(this).closest('#tabs').find('.TabsContainer [class^="tabbody"]').removeClass('active').addClass('nonactive');
    $(this).closest('#tabs').find('.TabsContainer [class*="tabbody'+tabname+'"]').removeClass('nonactive').addClass('active');
});