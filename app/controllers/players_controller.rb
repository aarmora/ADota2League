class PlayersController < ApplicationController
  def new
  	redirect_to @current_user if @current_user
    @current_tab = "signup"
  end

  def show
    @player = Player.find(params[:id])
    @current_tab = @current_user && @player.id == @current_user.id ? "myinfo" : ""
    @open_season = Season.where(:registration_open => true).exists?
    @player_comments = PlayerComment.where(:recipient_id => params[:id]).order("created_at desc")
  end

  def update
    @player = Player.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless Permissions.can_edit? @player
    respond_to do |format|
      if @player.update_attributes(player_params)
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
    @player_comment.attributes = player_comment_params
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

  def register_caster
    #attempt to find them in the Stripe DB first
      if @current_user.stripe_customer_id.nil?
        customer = Stripe::Customer.create(
        :description => @current_user.name,
        :email => @current_user.email,
        :metadata => {:user => @current_user.id, :participant_id => @current_user.steamid},
        :card  => params[:stripeToken]
      )
      else
        customer = Stripe::Customer.retrieve(@current_user.stripe_customer_id)
        customer.card = params[:stripeToken]
        customer.save
      end

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => 300,
        :description => "Caster Registration Fee",
        :statement_description => "AD2L Caster Fee",
        :metadata => {
          :customer => @current_user.name,
          :customer_id => @current_user.id
        },
        :currency    => 'usd'
      )

      # update our records
      @current_user.email = params[:stripeEmail] if @current_user.email.nil?
      @current_user.stripe_customer_id = customer.id
      @current_user.caster = true
      @current_user.save!

      flash[:notice] = "You have been successfully registered as a caster! "
      redirect_to @current_user
  end

  def no_emails
    @player = Player.find(params[:id])
    if params[:unsubscribe_key] == @player.unsubscribe_key
      @player.receive_emails = false
      @player.save!
      flash[:notice] = "You have been successfully unsubscribed from future emails!"
      redirect_to @player
    else
      flash[:notice] = "Doesn't look like you have permission to unsubscribe for this player."
      redirect_to @player
    end
  end

  private

  def player_params
    role = @current_user.role_for_object(@player)
    if role == :caster
      params.require(:player).permit(:name, :bio, :email, :time_zone, :freeagentflag, :role, :mmr, :hours_played, :steamid, :receive_emails, :real_name, :country, :avatar, :twitch, :region)
    elsif role == :admin
      params.require(:player).permit(:name, :bio, :email, :time_zone, :freeagentflag, :role, :mmr, :hours_played, :steamid, :receive_emails, :real_name, :country, :avatar, :twitch, :region, :caster)
    else
      params.require(:player).permit(:name, :bio, :email, :time_zone, :freeagentflag, :role, :mmr, :hours_played, :steamid, :receive_emails)
    end
  end

  def player_comment_params
    params.require(:player_comment).permit(:commenter_id, :recipient_id, :comment)
  end
end
