class TeamSeasonsController < ApplicationController

  def create
    head :forbidden and return unless @current_user
    @season = Season.find(params[:team_season][:season_id])
    if @season.team_tourney == true
      @participant = Team.find(params[:team_season][:participant_id])
    elsif Permissions.user_is_site_admin?
      @participant = Player.find(params[:team_season][:participant_id])
    else
      @participant = @current_user
    end
    head :forbidden and return unless Permissions.can_edit? @participant

    unless @participant.seasons_available_for_registration.include?(@season) || Permissions.user_is_site_admin?
      flash[:error] = "It looks like you've already registered for this tournament or another one in the same season. You may only register for ONE of the season four leagues. Please check below what you are already registered for and try again."
      redirect_to @participant
      return
    end

    @ts = @season.team_seasons.build
    @ts.participant = @participant

    # we're going to skip all the payment stuff if it's free!
    # If the user is an admin, we'll assume he's adding them as paid too (redo this later if you want)
    if @season.current_price == 0 || Permissions.user_is_site_admin?
      @ts.price_paid_cents = 0 # If admins added them, they technically didn't pay
      @ts.paid = true
    end
    @ts.save!

    if Permissions.user_is_site_admin?
      flash[:notice] = "Added #{@participant.name} to #{@season.title}"
      redirect_to manage_season_path(@ts.season_id)
    elsif @season.current_price == 0
      flash[:notice] = "You have been registered for " + @season.title
      redirect_to @season
    else
      # redirect to payment for this season path
      redirect_to @ts
    end
  end

  # payment page
  def show
    if @current_user
      @current_user.email = nil
    end
    @ts = TeamSeason.find(params[:id])
    head :forbidden and return unless Permissions.can_edit? @ts.participant

    if session[:current_user][:twitter]
      puts "har be twitter"
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = session[:current_user][:twitter][:auth_token]
        config.access_token_secret = session[:current_user][:twitter][:auth_secret]
      end

      discounted = false
      tweeted = false
      followed = false
      if twitter_client.friendship?(twitter_client.user, DOTA_TWITTER_ACCOUNT).inspect
        followed = true
      end
      # Depending on what requirements we want, we could use search more efficently instead
      @twitters = twitter_client.user_timeline(twitter_client.user.id, {exclude_replies: true, include_rts: false, count: 5}).each do |tweet|
        if (tweet.text.include? "@adota2l") && (tweet.text.include? "http://amateurdota2league.com") && (tweet.text.include? ("@namecheap"))
          tweeted = true
        end
      end
      if tweeted == true && followed == true
        discounted = true
      end
    end

  end

  # payment callback page and admin overrides
  def update
    @ts = TeamSeason.find(params[:id])
    if params[:team_season]
      head :forbidden and return unless Permissions.can_edit? @ts.participant
      respond_to do |format|
        if @ts.update_attributes(params[:team_season], :as => @current_user.role_for_object(@ts))
          format.html { redirect_to(manage_season_path(@ts.season_id), :notice => 'TeamSeason was successfully updated.') }
          format.json { respond_with_bip(@ts) }
        else
          format.html { redirect_to(manage_season_path(@ts.season)) }
          format.json { respond_with_bip(@ts) }
        end
      end
    else
      head :forbidden and return unless Permissions.can_edit? @ts.participant

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
        :amount      => @ts.season.current_price,
        :description => "AD2L #{@ts.season.title} Entry Fee",
        :statement_description => "Entry Fee",
        :metadata => {
          :season => @ts.season.id,
          :team => @ts.participant.id,
          :team_season => @ts.id,
          :was_late => @ts.season.late_fee_applies ? true : false
        },
        :currency    => 'usd'
      )

      # update our records
      @current_user.email = params[:stripeEmail] if @current_user.email.nil?
      @current_user.stripe_customer_id = customer.id
      @current_user.save!

      @ts.paid = true
      @ts.price_paid_cents = @ts.season.current_price
      @ts.save!

      flash[:notice] = "You have been successfully registered for " + @ts.season.title
      redirect_to @ts.participant
    end
  rescue Stripe::InvalidRequestError => e
    flash[:error] = e.message
    redirect_to @ts
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to @ts
  end

  def destroy
    @ts = TeamSeason.find(params[:id])
    head :forbidden and return unless Permissions.can_edit? @ts.participant

    title = @ts.season.title
    # TODO: Think about refunds here
    @ts.destroy

    flash[:notice] = "You have withdrawn from " + title
    redirect_to @ts.participant
  end
end
