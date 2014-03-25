class PlayersController < ApplicationController
  def index
  	@current_tab = "freeagents"
    @freeagents = Player.where(:freeagentflag => true)
    @player = @current_user ? Player.find(@current_user.id) : nil
  end

  def new
  	redirect_to edit_player_path(@current_user) if @current_user
    @current_tab = "signup"
  end

  def show
    @player = Player.find(params[:id])
    @can_edit = @current_user && (@current_user.id == @player.id || @current_user.is_admin?)
    @current_tab = @current_user && @player.id == @current_user.id ? "myinfo" : ""
  end

  def update
    raise ActionController::RoutingError.new('Not Found') unless @current_user && (params[:id].to_i == @current_user.id || @current_user.is_admin?)
    @player = Player.find(params[:id])
    respond_to do |format|
      if @player.update_attributes(params[:player], :as => @current_user.permission_role)
        format.html { redirect_to(@player, :notice => 'Player was successfully updated.') }
        format.json { respond_with_bip(@player) }
      else
        format.html { render :action => "show" }
        format.json { respond_with_bip(@player) }
      end
    end
  end
end
