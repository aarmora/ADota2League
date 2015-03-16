class ApplicationController < ActionController::Base
  include Permissions

	before_filter :load_user
  before_filter :check_active_streams
  before_filter :load_seasons_for_nav

  protect_from_forgery

  def load_user
    Permissions.current_user = nil
    # Lookup the player either by steamId (temp) or by userId (new)
    @current_user = if session[:current_user] && !session[:current_user][:id]
      # We don't know where it's stored at the moment since old sessions are lurking
      Player.find_by(:steamid => session[:current_user][:uid] || session[:current_user][:steam][:uid])
    elsif session[:current_user]
      Player.find_by_id(session[:current_user][:id])
    end

    return unless @current_user

    # Set the account here to convert the session to new style
    session[:current_user][:id] = @current_user.id

    # Update avatars for old-style logins
    # TODO: Just do this when they login once we get most people
    if @current_user && session[:current_user][:image] && !session[:current_user][:steam]
      @current_user.avatar = session[:current_user][:image]
      @current_user.save
    end

    Permissions.current_user = @current_user
  end

  def load_seasons_for_nav
    @active_seasons = Rails.cache.fetch("active_seasons", :expires_in => 180.seconds) do
      Season.where(active: true)
    end
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
