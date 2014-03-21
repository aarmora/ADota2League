class PlayersController < ApplicationController
  def index
  	@current_tab = "freeagents"
    @freeagents = Player.where(:freeagentflag => true)
  end
  
  def new
  	redirect_to edit_player_path(@current_user) if @current_user
    @current_tab = "signup"
  end
  
  def edit
  	raise ActionController::RoutingError.new('Not Found') unless @current_user && (params[:id].to_i == @current_user.id || @current_user.is_admin?)
  	@player = @current_user.is_admin? ? Player.find(params[:id]) : @current_user
    @current_tab = "myinfo"
  end
  
  def update
  	@player = @current_user.is_admin? ? Player.find(params[:id]) : @current_user
  	@player.update_attributes!(params[:player], :as => @current_user.role)
  	
  	# TODO: Maybe we'll have a player page to go to by default eventually, for now we have to do a page that exists
  	redirect_to root_path
  end

end
