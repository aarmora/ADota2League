class SoloLeaguesController < ApplicationController	
	before_filter :verify_admin

	def index
		#redirect_to show
	end

	def show
		if params[:id]
			@season = Season.find(params[:id])
		else
			@season = Season.where(:team_tourney => false, :active => true).first
		end

	end
end
