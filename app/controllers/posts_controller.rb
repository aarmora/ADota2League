class PostsController < ApplicationController
	before_filter :verify_admin

	def index
	end

	def create
		@post = Post.new
		@post.attributes = params[:post]
		@post.author_id = @current_user.id
		@post.save!
		redirect_to root_path
	end


  def verify_admin
  	raise ActionController::RoutingError.new('Not Found') unless @current_user && @current_user.is_admin?
  end
end
