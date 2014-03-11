class TeamsController < ApplicationController
	def index
	end
	def show
		# TODO: Is this mess ok?
		@team = Team.includes({:team_seasons => [:season], :players => [], :away_matches => [:away_team, :home_team], :home_matches => [:away_team, :home_team]}).find(params[:id])
		@captain_viewing = @current_user && @current_user.id == @team.captain_id
	end
end
