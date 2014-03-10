# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#freeagent page JS
    $(document).ready(function(){
        $('a.rss-title').attr('href', '/forums').attr("target", "_blank")
        $('a.rss-item').attr("target", "_blank")
    })
    $(document)
    .on('change', '#role', function () { 
        $.get('ajax.asp', {role:$(this).val(), playerkey:$(this).attr("playerkey"), action:6})
    })
    .on('click', '#agentsubmit', function () {
        var agentemail = $('#agentemail').val();
        if ($('#agentname').val() == "") {
            alert('Sorry, you can\'t be team nothing.')
            return false;
        }
        if (IsEmail(agentemail) == false) {
            alert('An invalid email address is like a hand of midas on Chen.  Just doesn\'t work.')
            return false;
        }
        $.get("ajax.asp", { agentname: $('#agentname').val(), agentemail: agentemail, role: $('#agentrole').val(), action: 2 }, function () {
            $('#agentemail').val('');
            $('#agentname').val('');
            $('#agentrole').val('');
            alert('Agency submitted!  Now, hopefully you won\'t be like the lonely druid.')
            window.location.replace("/freeagent.asp")
        })
    })

#entry page JS
   $(document)
    .on('click', '.teamsubmit', function () {
        var $this = $(this).closest('.active')
        var cptemail = $this.find('.cptemail').val();
        var teamname = $this.find('.teamname').val()
        if ( teamname == "") {
            alert('Sorry, you can\'t be team nothing.')
            return false;
        }
        if (IsEmail(cptemail) == false) {
            alert('An invalid email address is like a hand of midas on Chen.  Just doesn\'t work.')
            return false;
        }
        if ($this.find('.region:checked').length < 1) {
            alert('Pick the best region that applies, please.  Don\'t fight it.')
            return false;
        }
        $.get("ajax.asp", { teamname: teamname, cptemail: cptemail, action: 1, season: $(this).attr("season"), region:$this.find('.region:checked').val() }, function () {
            $this.find('.cptemail').val('');
            $this.find('.teamname').val('');
            alert('Team submitted!')
            window.location.replace("/teampage.asp")
        })
    })
    .on('click', '.agentsubmit', function () {
        var $this = $(this)
        var agentemail = $('.agentemail').val();
        var role = $('.agentrole').val()
        if (IsEmail(agentemail) == false) {
            alert('An invalid email address is like a hand of midas on Chen.  Just doesn\'t work.')
            return false;
        }
        $.get("ajax.asp", { agentemail: agentemail, role: role, action: 2 }, function () {
            $this.find('.agentemail').val('');
            $this.find('.agentrole').val('');
            alert('Agency submitted!  Now, hopefully you won\'t be like the lonely druid.')
            window.location.replace("/freeagent.asp")
        })
    })
    .on('click', '.jointeam', function () {
        var $this = $(this)
        var teamkey = $('.teamkey').val()
        var joineremail = $('.joineremail').val()
        if (teamkey == "") {
            alert('Hrm...I don\'t know a team with that team key...')
            return false;
        }
        if (IsEmail(joineremail) == false) {
            alert('An invalid email address is like a hand of midas on Chen.  Just doesn\'t work.')
            return false;
        }
        $.get("ajax.asp", { teamkey: teamkey, agentemail: joineremail, action: 3 }, function (data) {
            if (data == "invalidteamkey") {
                alert("Sorry.  That team key doesn\'t seem to be um...well...valid.  Try again?")
                $this.val('');
                $('#teamkey').focus();
            }
            else {
                $this.find('.teamkey').val('');
                $this.find('.joineremail').val('');
                alert('Done.  Joined.  You did it.  Yay!')
                window.location.replace("/teampage.asp")
            }
        })
    })