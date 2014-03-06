class MatchesController < ApplicationController
	def index
		@leagues = Dota.history("where league_id = 193")
	end
end
