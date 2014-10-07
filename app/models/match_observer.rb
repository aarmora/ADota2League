class MatchObserver < ActiveRecord::Observer
	def after_save(match)
		# This will reset the season page associated with this match
		controller = ActionController::Base.new
		controller.expire_fragment("seasonPage-" + match.season_id.to_s) unless match.season_id.nil?
	end

  def after_create(match)
    if match.date && match.date > Time.now
      match.lobby_password = "ad2l" & rand(1000)
      match.save
    end
  end
end
