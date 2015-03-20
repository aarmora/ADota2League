class PostsController < ApplicationController
	before_filter :verify_admin

	def index
	end

	def create
		@post = Post.new
		@post.attributes = post_params
		@post.author_id = @current_user.id
		@post.save!
		redirect_to root_path
	end


  def verify_admin
  	raise ActionController::RoutingError.new('Not Found') unless Permissions.user_is_site_admin?
  end

  private
  def post_params
    if Permissions.user_is_site_admin?
      params.require(:post).permit(:text, :title, :author_id)
    end
  end
end
