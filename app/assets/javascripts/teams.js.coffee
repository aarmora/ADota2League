# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).on('click', '#updateteamname', function(){
    $('.toinput').each(function(){
        var playername = $(this).html()
        $(this).parent().append($('<input />'))
        $('.inputbox').attr('placeholder', 'Name')
        $(this).parent().find('input').addClass('inputbox teamname').val(playername)
        $(this).remove();
    })
    $(document).on('change', '.inputbox', function () {
        var $this = $(this)
        if($(this).val() == ""){
            alert('Sorry, your team name can\'t be   ')
            $this.focus();
        }
        else{
            $.get('ajax.asp', {teamname:$this.val(), teamkey:$('#imdone').attr("teamkey"), action:4}, function(){
                alert('Name changed.  May you win more games with this name!')
            })
        }
        $('#teamname').html($this.val())
    })
    $('#updateteamname').html('I\'m done').attr('id', 'imdone')
})
$(document).on('click', '#imdone', function(){
    var teamname = $('.teamname').val();
    $('.teamname').parent().append($('<span />'))
    $('.teamname').parent().find('span').html(teamname)
    $('.teamname').parent().find('span').addClass('teammembername toinput')
    $('#imdone').html('Update team name').attr('id', 'updateteamname')
    $('.teamname').remove();
})
$(document).on('click', '.bootfromteam', function(){
    var $this = $(this)
    $.get('ajax.asp', {playerkey:$(this).attr("playerkey"), teamkey:$(this).attr("teamkey"), action:5, steamid:$(this).attr("steamid")}, function(data){
        $this.parent().find('span').html('');
        $this.parent().find('.bootfromteam').remove();
        if(data == "redirect"){
            window.location.replace("/freeagent.asp")
        }
    })
})
//request match info from steam api
$(document).on('change', 'input', function(){
    $.get('ajax.asp', {action:9, matchkey:$(this).closest('tr').attr("matchkey"), HomeTeamFlag:$(this).closest('tr').attr("HomeTeamFlag"), Winna:$(this).closest("tr").find(".score:checked").attr("winna"), MatchID:$(this).closest("tr").find(".matchid").val()}, function(){
})

    //Get match info from API
    /*$.getJSON('apitalker.asp', {matchid:435847425, action:2}, function(data){
        for(var i = 0; i < data.result.players.length; i++){
            if(data.result.players[i].account_id == "435847425" || data.result.players[i].account_id == "125911951"){
                if(data.result.players[i].account_id == "80623424"){
                    var cptOneslot = data.result.players[i].player_slot
                    if(cptOneslot > 4){
                        var cptOneside = "dire"
                    }
                    else{
                        var cptOneside = "radiant"
                    }
                }
            }
        }
        if(data.result.radiant_win == false){
        }
    })*/
})
//delete team
$(document).on('click', '#removeteam', function(){
    if(confirm("Abandon your team?  Sure, you won't go in low priority.  But still.  Sad, right?")){
        $.get('ajax.asp', {teamkey:$(this).attr("teamkey"), action:8}, function(){
            window.location.replace("/entry.asp")
        })
    }
})
