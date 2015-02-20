class AuthenticationController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token
  skip_before_filter :load_user
  skip_before_filter :check_active_streams

  def steam_callback
    auth = request.env['omniauth.auth']
    @data = {
      nickname: auth.info['nickname'],
      name: auth.info['name'],
      image: auth.info['image'],
      country: auth.extra.raw_info['loccountrycode'],
      uid: auth.uid,
      timestamp: Time.now
    }
    generic_callback
  end

  def bnet_callback
    auth = request.env['omniauth.auth']
    @data = {
      battletag: auth.info['battletag'],
      uid: auth.uid,
      timestamp: Time.now
    }
    generic_callback
  end

  def generic_callback
    session[:current_user] ||= {}
    session[:current_user][request.env['omniauth.auth'].provider.to_sym] = @data

    # TODO: Change in the future for multiple login
    # Find the appopriate user
    @current_user = Player.find_or_create_by!(:steamid => session[:current_user][:steam][:uid]) do |user|
      # If they are a new user, ship them over to the profile page
      user.name = session[:current_user][:steam][:nickname]
      user.real_name = session[:current_user][:steam][:name]
      user.avatar = session[:current_user][:steam][:image]
      user.country = session[:current_user][:steam][:country]
      user.steam32id = user.steamid.to_i - 76561197960265728.to_i
      user.save!
      flash[:notice] = "Welcome to AD2L!  Your account has been created.  If you want to register a team or for tournaments, please click the register tab above. Play on!"
      redirect_to user and return
    end

    session[:current_user][:id] = @current_user.id

    redirect_to request.env['omniauth.origin'] || root_path
  end

  def logout
    reset_session
    redirect_to :controller => 'welcome'
  end

end