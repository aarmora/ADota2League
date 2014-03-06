class TeamsController < ApplicationController
	def index
		@teams = Team.where("season is not null")
		#@teamsmatches = Match.away_team.teamname.where("season is not null")
	end
	def show
		@team = Team.find(params[:id])
	end
end
