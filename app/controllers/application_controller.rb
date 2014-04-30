class ApplicationController < ActionController::Base
	before_filter :load_user
  before_filter :check_active_streams
  protect_from_forgery

  def load_user
  	# In rails 4, this would be .find_or_create_by! (:steamid => session[:current_user][:uid])
	  @current_user = Player.find_or_initialize_by_steamid(session[:current_user][:uid]) if session[:current_user]
  	# If they are a new user, ship them over to the profile page
  	if @current_user && @current_user.new_record?
      @current_user.steam32id = @current_user.steamid.to_i - 76561197960265728.to_i
  		@current_user.save!
  		redirect_to @current_user
    elsif @current_user
      Player.find(@current_user.id).update_attributes(:name => session[:current_user][:nickname])
  	end

    @can_edit = @current_user && @current_user.is_admin?
  end

  def check_active_streams
    @active_streams = Rails.cache.fetch("active_twitch_streams", :expires_in => 90.seconds) do
      twitch_accounts = ["amateurdota2league","amateurdota2league1"] + Player.where(:caster => true).select{|p| p.twitch}.map {|p| p.twitch.split('/').last }.compact
      Twitch.streams.find(:channel => twitch_accounts).select {|stream| stream.channel.status.downcase.include? "ad2l"}
    end
  end

  def verify_admin
    raise ActionController::RoutingError.new('Not Found') unless @current_user && @current_user.is_admin?
  end
end
