# app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback

  def index
    @current_tab = "index"
    @posts = Post.all.sort_by{|p| p[:created_at]}.reverse
  end

  def community
    @current_tab = "community"
    @casters = Player.where(:caster => true)
  end

  def contact
    @current_tab = "contact"
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = { 
    	:nickname => auth.info['nickname'],
      :image => auth.extra.raw_info['avatar'],
      :uid => auth.uid
    }
    
    redirect_to seasons_url
  end

  def logout
      reset_session
      redirect_to :controller => 'welcome'
  end
end