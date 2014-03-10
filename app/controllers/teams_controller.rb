class TeamsController < ApplicationController
	def index
		@teams = Season.first.teams
		@matches = Season.first.matches
		#@matchesrefined = @matches.select! {|match| match.home_team.season && match.away_team.season}
	end
	def show
		@team = Team.find(params[:id])
	end
end
