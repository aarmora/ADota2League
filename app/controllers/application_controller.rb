class ApplicationController < ActionController::Base
	before_filter :load_user
  before_filter :check_active_streams
  protect_from_forgery

  def load_user
  	# In rails 4, this would be .find_or_create_by! (:steamid => session[:current_user][:uid])
	  @current_user = Player.find_or_initialize_by_steamid(session[:current_user][:uid]) if session[:current_user]

  	# If they are a new user, ship them over to the profile page
  	if @current_user && @current_user.new_record?
  		@current_user.save!
  		redirect_to edit_player_path(@current_user)
  	end
  end

  def check_active_streams
    @active_streams = Rails.cache.fetch("active_twitch_streams", :expires_in => 90.seconds) do
      twitch_accounts = ["amateurdota2league","amateurdota2league1"] + Player.where(:caster => true).select{|p| p.twitch}.map {|p| p.twitch.split('/').last }.compact
      Twitch.streams.find(:channel => twitch_accounts).select {|stream| stream.channel.status.downcase.include? "ad2l"}
    end
  end
end
