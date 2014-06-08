class TeamsController < ApplicationController

  def index
	end

	def show
		# TODO: Is this mess ok?
		@team = Team.includes({:team_seasons => [:season], :players => [], :away_matches => [:away_team, :home_team], :home_matches => [:away_team, :home_team]}).find(params[:id])
		if @current_user
			@current_user.teams.each do |team|
				if @team.id == team.id
					@current_tab = "teampage"
				end
			end
		end
		@roster = @team.players.sort_by {|p| p.id == @team.captain_id ? 0 : 1}
    	@players = Player.order(:name).all
  		@casters = Player.order(:name).where(:caster => true)
	end

	def create
		raise unless @current_user
		@team = Team.new
		@team.captain_id = @current_user.id
		@team.attributes = params[:team]
		@team.players << @current_user
    	@team.mmr = @team.originalmmr || @team.default_mmr
		@team.save!
		redirect_to @team
	end

	def update
		@team = Team.find(params[:id])
		raise unless Permissions.can_edit? @team
		respond_to do |format|
			if @team.update_attributes(params[:team], :as => @current_user.permission_role)
		        format.html { redirect_to(@team, :notice => 'Player was successfully updated.') }
		        format.json { respond_with_bip(@team) }
		    else
		        format.html { render :action => "show" }
		        format.json { respond_with_bip(@team) }
		   	end
		end
	end

	def destroy
		@team = Team.find(params[:id])
		raise unless Permissions.can_edit? @team

		if @team.matches.count == 0
			@team.destroy
		else
			# TODO: Alright, so here's the deal...we probably want to keep a ghost record of this team
			# what exactly that looks like I'm not sure. I think we'd remove the captain and flag the team as inactive
			# this would prevent them from being scheduled into games

			@team.captain_id = nil
			@team.active = false
			# @team.matches.future # mark each as forfeit?
			@team.save!
		end
		redirect_to root_path
	end

	# Endpoints used for handling associating players with teams
  def add_players
    @team = Team.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @team
    @team.players << Player.find(params[:players].select{|i| i.to_i > 0})
    redirect_to @team
  end

  def remove_players
  	@team = Team.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @team
  	@team.players.delete(Player.find(params[:players].select{|i| i.to_i > 0}))
  	redirect_to @team
  end

end
