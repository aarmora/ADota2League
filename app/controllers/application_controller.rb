class ApplicationController < ActionController::Base
	before_filter :load_user
  protect_from_forgery
  
  def load_user
  	# In rails 4, this would be .find_or_create_by! (:steamid => session[:current_user][:uid])
  	@current_user = Player.find_or_initialize_by_steamid(session[:current_user][:uid]) if session[:current_user]
  	
  	# If they are a new user, ship them over to the profile page
  	if @current_user.new_record?
  		@current_user.save!
  		redirect_to edit_player_path(@current_user)
  	end
  end
end
