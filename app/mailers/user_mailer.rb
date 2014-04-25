class UserMailer < ActionMailer::Base
  default from: "Amateurdota2league@gmail.com"

   def match_comment_email(match_id)
   	@match = Match.find(match_id)
    @home_team_roster = @match.home_team.players
    @away_team_roster = @match.away_team.players
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

  def free_agent_page(player)
    unless player.email.nil?
      @player = player    
      mail(to: player.email, subject: 'A brand new free agent page!') 
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

end
