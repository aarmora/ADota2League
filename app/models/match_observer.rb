class MatchObserver < ActiveRecord::Observer
	def after_save(match)
		# This will reset the season page associated with this match

    # Attributes that affect caching
    attrs = ["date", "caster_id", "home_score", "away_score", "forfeit", "home_participant_id", "away_participant_id", "home_participant_type", "away_participant_type"]
    if (match.changes.keys & attrs).length > 0
      controller = ActionController::Base.new
      controller.expire_fragment("seasonPage-" + match.season_id.to_s) unless match.season_id.nil?
    end

    # Check for score changes and tournaments
    if (match.changes["home_score"] || match.changes["away_score"]) && !match.season.round_robin?
      match.logger.info("Score change detected for tournament match; processing")
      # Update or advance people, assume ties aren't possible in a playoff
      if match.winner_match_id
        winner = match.home_score >= match.away_score ? match.home_participant : match.away_participant
        m = Match.find(match.winner_match_id)
        m.remove_participants(match.home_participant, match.away_participant)  # In case it's an update
        m.add_participant(winner)
      end

      if match.loser_match_id
        loser = match.home_score >= match.away_score ? match.away_participant : match.home_participant
        m = Match.find(match.loser_match_id)
        m.remove_participants(match.home_participant, match.away_participant) # In case it's an update
        m.add_participant(loser)
      end
    end
	end

  def after_create(match)
    if match.date && match.date > Time.now
      match.lobby_password = "ad2l" + rand(1000).to_s
      match.save
    end
  end
end
