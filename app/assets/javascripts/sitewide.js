
function IsEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

$(document).ready(function() {
    // JQuery Tooltips
    $('[data-toggle=tooltip]').tooltip();

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
            $(this).find(".glyphicon").removeClass("glyphicon-chevron-up").addClass("glyphicon-chevron-down");
            $("#LiveGames").css("top", pulloutZeroOffset() * -1);
        } else {
            $("#LiveGames").css("top", 0);
            $(this).find(".glyphicon").removeClass("glyphicon-chevron-down").addClass("glyphicon-chevron-up");
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

//Reset ajax forms on ajax:complete
$(document).ready(function(){
    $("#top_plays_form").bind('ajax:complete', function(){
        $('#top_plays_form').trigger('reset');
        alert('Thanks for submitting this play!')
    });
});