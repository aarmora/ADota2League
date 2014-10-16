class InhousesController < ApplicationController

	def index
		@games = Dota.history(:league_id => 2047)

		@all_games = Array.new

		@games.raw_history["matches"].each do |game|
			this_game = Dota.match(game["match_id"])
			@all_games.push this_game
		end

		render :json => @all_games
	end

end