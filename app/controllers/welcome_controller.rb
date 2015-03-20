# app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  def index
    @current_tab = "index"
  end

  def get_posts
    @posts = HTTParty.get('http://api.tumblr.com/v2/blog/blog.amateurdota2league.com/posts?api_key=R53BwtQewNSXChah0yFwYhbj8ewGZWTt6Y1y4lzsDxCwUH0SPt')
    render :json => @posts
  end

  def community
    @current_tab = "community"
    @casters = Player.where(:caster => true)
    @admins = Player.where(:admin => true)
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
end