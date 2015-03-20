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

    # Check for discount applications
    discount_amount
  end

  def paypal
    @ts = TeamSeason.find(params[:id])
    head :forbidden and return unless Permissions.can_edit? @ts.participant

    paypal_request = generate_paypal_request
    payment_request = generate_paypal_payment_request
    paypal_response = paypal_request.setup(
      payment_request,
      paypal_success_team_season_url(@ts),
      paypal_error_team_season_url(@ts),
      {
        :no_shipping => true,
        :pay_on_paypal => true,
        :allow_note => false
      }
    )
    redirect_to paypal_response.redirect_uri
  end

  def generate_paypal_request
    @paypal_request ||= Paypal::Express::Request.new(
      :username   => ENV['PAYPAL_USERNAME'],
      :password   => ENV['PAYPAL_PASSWORD'],
      :signature  => ENV['PAYPAL_SIGNATURE']
    )
  end

  def generate_paypal_payment_request
    price = (@ts.season.current_price - discount_amount) / 100.0
    @payment_request ||= Paypal::Payment::Request.new(
      :currency_code => :USD, # if nil, PayPal use USD as default
      :amount        => price,
      :description => "AD2l #{@ts.season.title} Entry Fee"
    )
  end

  def paypal_callback_success
    @ts = TeamSeason.find(params[:id])
    begin
      paypal_response = generate_paypal_request.checkout!(
        params[:token],
        params[:PayerID],
        generate_paypal_payment_request
      )
      info = paypal_response.payment_info.first
      @ts.paid = true
      @ts.price_paid_cents = info.amount.total * 100
      @ts.save!
      flash[:notice] = "You have been successfully registered for " + @ts.season.title

      notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
      notifier.ping "#{@ts.participant} has just paid #{@ts.price_paid_cents} for @ts.season.title", icon_url: "http://icons.iconarchive.com/icons/chrisbanks2/cold-fusion-hd/128/paypal-icon.png"

      redirect_to @ts.participant
    rescue Exception => e
      ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => paypal_response})
      flash[:error] = "There was an error processing your payment. Please check your Paypal records. Perhaps your card was declined? Email us if you continue to have issues."
      redirect_to @ts.participant
    end
  end

  def paypal_callback_error
    @ts = TeamSeason.find(params[:id])
    flash[:error] = "There was an error processing your payment, please try again"
    redirect_to @ts
  end

  private def discount_amount
    # memoize to preserve api calls
    @discount_amount ||= qualifies_for_twitter_discount? ? 100 : 0
  end

  private def qualifies_for_twitter_discount?
    if session[:current_user][:twitter]
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = session[:current_user][:twitter][:auth_token]
        config.access_token_secret = session[:current_user][:twitter][:auth_secret]
      end

      begin
        followed = twitter_client.friendship?(twitter_client.user, DOTA_TWITTER_ACCOUNT)
        #This is the better way to do it, when the search is working.
        #result = twitter_client.search("amateurdota2league.com @adota2l @namecheap from:#{session[:current_user][:twitter][:handle]}", count: 10).take(1)
        results = twitter_client.user_timeline(session[:current_user][:twitter][:handle], count: 10)
        puts results
        tweeted = results.any? do |tweet|
          # TODO: Read the uris to check for the url entity
          urls = tweet.urls
          #Just in case there is more than one link
          tweet_with_url = urls.any? do |url|
            url.display_url.include?('amateurdota2league.com')
          end
          tweet.text.include?('@adota2l') && tweet.text.include?('@namecheap') && tweet_with_url ##This last part doesn't work because twitter changes the link
        end
      rescue
        @twitter_error = true
      end
      tweeted == true && followed == true
      #followed == true
    else
      false
    end
  end

  # payment callback page and admin overrides
  def update
    @ts = TeamSeason.find(params[:id])
    if params[:team_season]
      head :forbidden and return unless Permissions.can_edit? @ts.participant
      respond_to do |format|
        if @ts.update_attributes(team_season_params)
          format.html { redirect_to(manage_season_path(@ts.season_id), :notice => 'TeamSeason was successfully updated.') }
          format.json { respond_with_bip(@ts) }
        else
          format.html { redirect_to(manage_season_path(@ts.season)) }
          format.json { respond_with_bip(@ts) }
        end
      end
    else
      head :forbidden and return unless Permissions.can_edit? @ts.participant

      # if the price is 0 or less after discounts, then we don't need to run a charge
      price = @ts.season.current_price - discount_amount
      if price > 0
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
          :amount      => @ts.season.current_price - discount_amount,
          :description => "AD2L #{@ts.season.title} Entry Fee",
          :statement_description => "AD2L #{@ts.season.title}",
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
      end

      @ts.paid = true
      @ts.price_paid_cents = @ts.season.current_price - discount_amount
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

  private

  def team_season_params
    if @current_user.role_for_object(@ts) == :admin
      params.require(:team_season).permit(:checked_in, :paid, :division, :season)
    else
      params.require(:team_season).permit(:checked_in)
    end
  end
end
