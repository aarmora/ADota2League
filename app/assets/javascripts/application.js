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

function IsEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}
$.getJSON('apitalker.asp', {action:3}, function(data){
    if(data._total > 0){
        $('#closedlivegames').css({'display':'block'});
        var livegamesstuff = "";
        total = parseInt(data._total * 40) + "px";
        $.each(data.streams, function(index, streams){
            livegamesstuff = livegamesstuff +  "<div class='twitchtitle'>" + streams.channel.status + "</div><a href="+ streams.channel.url +" target='_blank' class='twitchlink'>" + streams.channel.name +"</a><div style='clear:both'></div>";
        })
        $('#livegamescontent').html(livegamesstuff);
    }
});
$(document).on('click', '#closedlivegames', function(){
    $(this).animate({'top':total});
    $('#livegamescontent').css({'display':'block'}).animate({'height':total});
    $(this).attr('id', 'openlivegames');
});
$(document).on('click', '#openlivegames', function(){
    $(this).animate({'top':'-1px'});
    $('#livegamescontent').animate({'height':'0px'}, function(){
        $('#livegamescontent').css({'display':'none'});
    })
    $(this).attr('id', 'closedlivegames');
});
//tabs js
$(document).on('click', '#tabs .nonactive[id^="tab"]', function(){
    var tabname = $(this).attr('id').replace('tab', '');
    $(this).closest('#tabs').find('.active[id^="tab"]').removeClass('active').addClass('nonactive');
    $(this).removeClass('nonactive').addClass('active');
    $(this).closest('#tabs').find('.TabsContainer [class^="tabbody"]').removeClass('active').addClass('nonactive');
    $(this).closest('#tabs').find('.TabsContainer [class*="tabbody'+tabname+'"]').removeClass('nonactive').addClass('active');
});