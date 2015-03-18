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

	def reg_form_partial
    @team = Team.find(params[:team_id])
    render :partial => "seasons/registration_form", :locals => {:participant => @team}
  end

	def tweet_and_follow
		render layout: "no_chrome"
	end
end
