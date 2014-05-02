class RegisterController < ApplicationController
	def index
	  	redirect_to new_register_path(:id => @current_user) if @current_user
	    @current_tab = "register"
	end

	def new
		@player = Player.find(params[:id])
    	@open_season = Season.where(:registration_open => true).exists?
	    @current_tab = "register"
	end
	def show
		@team = Team.find(params[:id])
	    @current_tab = "register"
	end

end
