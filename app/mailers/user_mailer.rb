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

  def free_agent_page
    @player = Player.find(205)
    @player.each do |player| 
      mail(to: player.email, subject: 'Someone has commented on your match!')      
    end
  end

end
