class InhousesController < ApplicationController

	def index
	end

	def show
		@current_tab = "inhouse"

		@inhouse_players = Inhouseleaderboard.where(:season_id => params[:id]).includes(:player)
		
	end

end