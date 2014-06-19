class ApplicationController < ActionController::Base
  include Permissions

	before_filter :load_user
  before_filter :check_active_streams
  protect_from_forgery

  def load_user
  	# In rails 4, this would be .find_or_create_by! (:steamid => session[:current_user][:uid])
    Permissions.current_user = nil
	  @current_user = Player.find_or_initialize_by_steamid(session[:current_user][:uid]) if session[:current_user]
  	# If they are a new user, ship them over to the profile page
  	if @current_user && @current_user.new_record?
      @current_user.steam32id = @current_user.steamid.to_i - 76561197960265728.to_i
  		@current_user.save!
      flash[:notice] = "Welcome to AD2L!  Your account has been created.  If you want to register a team, please click the register tab above.  If you would like to sign up as a free agent, just toggle your free agent status below!  Play on!"
      redirect_to @current_user
    elsif @current_user
      Player.find(@current_user.id).update_attributes(:name => session[:current_user][:nickname])
  	end

    Permissions.current_user = @current_user
    @all_seasons = Season.all
  end

  def check_active_streams
    @active_streams = Rails.cache.fetch("active_twitch_streams", :expires_in => 90.seconds) do
      twitch_accounts = ["amateurdota2league","amateurdota2league1"] + Player.where(:caster => true).select{|p| p.twitch}.map {|p| p.twitch.split('/').last }.compact
      begin
        Twitch.streams.find(:channel => twitch_accounts).select {|stream| stream.channel.status.downcase.include? "ad2l"}
      rescue
        []
      end
    end
    @official_streams = @active_streams.select { |s| ["amateurdota2league","amateurdota2league1"].include? s.channel.name }
  end

  def verify_admin
    raise ActionController::RoutingError.new('Not Found') unless Permissions.user_has_permissions?
  end
end
