
function IsEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

$(document).ready(function() {
    /* Activating Best In Place */
    jQuery(".best_in_place").best_in_place();

    // Intercept all AJAX requests to add in rails auth token where needed
    jQuery(document).ajaxSend(function(event, request, settings) {
      if (typeof(AUTH_TOKEN) == "undefined") return;
      if (settings.type == 'GET') return; // Don't add anything to a get request let IE turn it into a POST.
      settings.data = settings.data || "";
      settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
    });

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

    // Activate select2 fields

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