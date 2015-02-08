class UserMailer < ActionMailer::Base
  default from: "Amateurdota2league@gmail.com"

   def match_comment_email(match_id)
   	@match = Match.find(match_id)
    @home_team_roster = @match.home_participant.players
    @away_team_roster = @match.away_participant.players
    @url  = 'http://amateurdota2league.com/matches/'+match_id
    #@match_comment = Matchcomment.where(:match_id: match_id)
    @home_team_roster.each do |player|
    	@player = player
    	mail(to: player.email, subject: 'Someone has commented on your match!')
    end
    @away_team_roster.each do |player|
    	@player = player
    	mail(to: player.email, subject: 'Someone has commented on your match!')
    end
  end

  def season4_reminder(player, playerz)
    unless player.email.nil?
      @player = player
      puts player.email
      puts player.id
      mail(to: player.email, subject: "AD2L Solo Tourney!")
    end
  end

  def top_plays_email(name, email, time, match_id, comments)
    @name = name
    @email = email
    @time = time
    @match_id = match_id
    @comments = comments
    mail(to: ENV['TOP_PLAY_EMAIL'], cc: ENV['GMAIL_ACCOUNT'], subject: "AD2L top play!")
  end

  def reschedule_proposed(proposed_date, match, proposer)
    @match = match;
    @proposer = proposer;
    if @match.home_participant.captain == @current_user
      @recipient = @match.away_participant.captain
    else
      @recipient = @match.home_participant.captain
    end
    if @recipient.email
      mail(to: @recipient.email, subject: "Proposed schedule change")
    end

  end

  def playoff_email(player)

    @player = player

    if @player.email
      mail(to: @player.email, subject: "Playoffs!")
    end

  end

end
