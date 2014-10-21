class InhousesController < ApplicationController

	def index
		
		redirect_to inhouse_url(1)
	end

	def show
		@current_tab = "inhouse"

		@inhouse_players = Inhouseleaderboard.where(:season_id => params[:id]).includes(:player)
		
	end

end