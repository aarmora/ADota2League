class InhousesController < ApplicationController

	def index
		
		redirect_to inhouse_url(2)
	end

	def show
		@current_tab = "inhouse"
		@ih_season_id = params[:id]

		@inhouse_players = Inhouseleaderboard.where(:season_id => params[:id]).includes(:player)
		
	end

end