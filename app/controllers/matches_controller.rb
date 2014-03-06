class MatchesController < ApplicationController
	def index
		@leaguematches = Dota.history(:league_id => 158)

		#@matchdetails = Dota.match(22345678)
	end
end
