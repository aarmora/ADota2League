class ApplicationController < ActionController::Base
	before_filter :load_user
  protect_from_forgery
  
  def load_user
  	# In rails 4, this would be .find_or_create_by! (:steamid => session[:current_user][:uid])
  	@current_user = Player.find_or_create_by_steamid(session[:current_user][:uid]) if session[:current_user]
  end
end
