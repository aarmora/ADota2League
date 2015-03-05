class RegisterController < ApplicationController
	def new
		if !@current_user
			render "register/logged_out"
		else
			@player = @current_user
		    @open_seasons = Season.where(:registration_open => true)
			@current_tab = "register"


		
      	end
	end

	def tweet_and_follow
	end
end
