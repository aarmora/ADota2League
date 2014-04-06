class MatchObserver < ActiveRecord::Observer
	def after_save(match)
		# This will reset the season page associated with this match
		controller = ActionController::Base.new
		controller.expire_fragment("seasonPage-" + match.season_id.to_s) unless match.season_id.nil?
	end
end
