class TeamsController < ApplicationController
	def index
		@player = @current_user.is_admin? ? Player.find(params[:id]) : @current_user
	end
	def show
		# TODO: Is this mess ok?
		@team = Team.includes({:team_seasons => [:season], :players => [], :away_matches => [:away_team, :home_team], :home_matches => [:away_team, :home_team]}).find(params[:id])
		@captain_viewing = @current_user && @current_user.id == @team.captain_id
		@current_user.teams.each do |team|
			if @team.id == team.id
				@casters = Player.where("role like '%caster%'")
				@current_tab = "teampage"
			end
		end
	end
	
	def create
		raise unless @current_user
		@team = Team.new
		@team.captain_id = @current_user.id
		@team.attributes = params[:team]
		@team.players << @current_user
		@team.save!
		redirect_to @team
	end
	
	def update
		@team = Team.find(params[:id])
		raise unless @team.captain_id == @current_user.id || @current_user.is_admin?
		@team.update_attributes!(params[:team], :as => @current_user.role)
		redirect_to @team
	end
	
	def destroy
		@team = Team.find(params[:id])
		raise unless @team.captain_id == @current_user.id || @current_user.is_admin?
		
		if @team.matches.count == 0
			@team.destroy
		else
			# TODO: Alright, so here's the deal...we probably want to keep a ghost record of this team
			# what exactly that looks like I'm not sure. I think we'd remove the captain and flag the team as inactive
			# this would prevent them from being scheduled into games
			
			# @team.captain_id = nil
			# @team.active = false
			# @team.matches.future # mark each as forfeit?
			# @team.save!
		end
		redirect_to root_path
	end
end
