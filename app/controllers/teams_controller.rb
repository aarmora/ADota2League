class TeamsController < ApplicationController
	def index
		@teams = Team.where("season is not null")
		@matches = Match.all
		#@matchesrefined = @matches.select! {|match| match.home_team.season && match.away_team.season}
	end
	def show
		@team = Team.find(params[:id])
	end
end
