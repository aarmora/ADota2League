class AdminController < ApplicationController
	before_filter :verify_admin

  def index
    @teams = Team.includes(:captain).all
    @players = Player.all
    @seasons = Season.all
  end
  def create
    raise unless @current_user
    @post = Post.new
    @post.author_id = @current_user.id
    @post.attributes = params[:post]
    @post.save!
    redirect_to admin_path
  end

  def players
    @players = Player.includes(:teams).all
  end

  def manage_season
    # Get weeks or something?

  end

  def verify_admin
  	raise ActionController::RoutingError.new('Not Found') unless @current_user && @current_user.is_admin? 
  end
end
