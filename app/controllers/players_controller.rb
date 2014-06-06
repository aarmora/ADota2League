class PlayersController < ApplicationController
  def index
  	@current_tab = "freeagents"
    @freeagents = Player.where(:freeagentflag => true)
    @player = @current_user ? Player.find(@current_user.id) : nil
  end

  def new
  	redirect_to @current_user if @current_user
    @current_tab = "signup"
  end

  def show
    @player = Player.find(params[:id])
    @current_tab = @current_user && @player.id == @current_user.id ? "myinfo" : ""
    @can_edit_player = @current_user && (@current_user.id == @player.id || @current_user.is_admin?)
    @open_season = Season.where(:registration_open => true).exists?
    @player_comments = PlayerComment.where(:recipient_id => params[:id]).order("created_at desc")
  end

  def update
    @player = Player.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @player
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


  def create_player_comment
    @player_comment = PlayerComment.new
    @player_comment.attributes = params[:player_comment]
    @player_comment.save!
    @player_comments = PlayerComment.where(:recipient_id => params[:player_comment][:recipient_id]).order("created_at desc")
    respond_to do |format|
      # Possibly email the player when a comment is made
      #UserMailer.match_comment_email(params[:matchcomment][:match_id]).deliver

     format.html { render :partial => 'player_comments', :object => @player_comments }
      #format.json { render :partial => 'match_comment', :object => @matchcomments }

    end
  end

  def delete_player_comment
    PlayerComment.find(params[:comment_id]).destroy
    render :nothing => true
  end


  def player_comments_partial
    @player_comments = PlayerComment.where(:recipient_id => params[:player_id]).order("created_at desc")
    render :partial => 'player_comments', :object => @player_comments
  end

  def endorse
    if @current_user
      @player = Player.find(params[:id])
      if params[:endorse].to_i == 1
        @player.endorsers << @current_user
      else
        @player.endorsers.delete(@current_user)
      end
    end

    respond_to do |format|
      format.html { redirect_to(@player) }
      format.json { render :json => {:endorsed => params[:endorse].to_i == 1} }
    end
  end


end
