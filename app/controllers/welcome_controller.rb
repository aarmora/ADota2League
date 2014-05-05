# app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback
  skip_before_filter :load_user, :only => :auth_callback
  skip_before_filter :check_active_streams, :only => :auth_callback

  def index
    @current_tab = "index"
    @posts = Post.all.sort_by{|p| p[:created_at]}.reverse
  end

  def community
    @current_tab = "community"
    @casters = Player.where(:caster => true)
  end

  def faq
    @current_tab = "faq"
  end

  def contact
    @current_tab = "contact"
    @admins = Player.where(:admin => true)
  end

  def top_plays_email
    name = params[:name]
    email = params[:email]
    time = params[:time]
    match_id = params[:match_id]
    comments = params[:comments]
    UserMailer.top_plays_email(name, email, time, match_id, comments).deliver
    render :nothing => true
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = {
    	:nickname => auth.info['nickname'],
      :image => auth.extra.raw_info['avatar'],
      :uid => auth.uid
    }

    redirect_to root_url
  end

  def logout
    reset_session
    redirect_to :controller => 'welcome'
  end
end