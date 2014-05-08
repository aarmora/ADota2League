class RegisterController < ApplicationController
	def index
	  	redirect_to new_register_path(:id => @current_user) if @current_user
	    @current_tab = "register"
	end

	def new
		@player = Player.find(params[:id])
		redirect_to register_index_path unless @current_user
    @open_season = Season.where(:registration_open => true).exists?
	  @current_tab = "register"
	end

	def show
		redirect_to register_index_path unless @current_user
		@team = Team.find(params[:id])
	  @current_tab = "register"
	end

end
