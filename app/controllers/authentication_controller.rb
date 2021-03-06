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

  def twitter_callback
    auth = request.env['omniauth.auth']
    @data = {
      handle: auth.info['nickname'],
      uid: auth.uid,
      timestamp: Time.now,
      auth_token: auth['credentials']['token'],
      auth_secret: auth['credentials']['secret']
    }

    generic_callback(false)
    redirect_to "/tweet_and_follow"
  end

  def generic_callback(redirect = true)
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

    if @current_user #update them when they relog in
      @current_user.name = session[:current_user][:steam][:nickname]
      @current_user.real_name = session[:current_user][:steam][:name]
      @current_user.avatar = session[:current_user][:steam][:image]
      @current_user.country = session[:current_user][:steam][:country]
      @current_user.save!
    end

    # Twitter Related updates
    if @current_user && session[:current_user] && session[:current_user][:twitter]
      @current_user.twitter = session[:current_user][:twitter][:handle]
      @current_user.save!
    end

    session[:current_user][:id] = @current_user.id

    redirect_to request.env['omniauth.origin'] || root_path if redirect
  end

  def logout
    reset_session
    redirect_to :controller => 'welcome'
  end

end