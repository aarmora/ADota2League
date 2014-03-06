# app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback

  def index
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = { 
    	:nickname => auth.info['nickname'],
      :image => auth.info['image'],
      :uid => auth.uid
    }
    
    redirect_to teams_url
  end

  def logout
      reset_session
      redirect_to :controller => 'welcome'
  end
end