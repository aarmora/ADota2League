class TeamSeasonsController < ApplicationController

  def create
    @team = Team.find(params[:team_season][:team_id])
    render :status => :forbidden and return unless @current_user && (@current_user.captained_teams.include?(@team) || @current_user.is_admin?)

    @season = Season.find(params[:team_season][:season_id])
    raise unless @team.seasons_available_for_registration.include? @season

    @ts = @season.team_seasons.build
    @ts.team = @team

    # we're going to skip all the payment stuff if it's free!
    if @season.current_price == 0
      @ts.price_paid_cents = @season.current_price
      @ts.paid = true
    end
    @ts.save!

    if @season.current_price == 0
      flash[:notice] = "You have been registered for " + @season.title
      redirect_to @team
    else
      # redirect to payment for this season path
      redirect_to @ts
    end
  end

  # payment page
  def show
    @ts = TeamSeason.find(params[:id])
    render :status => :forbidden and return unless @current_user && (@current_user.captained_teams.include?(@ts.team) || @current_user.is_admin?)
  end

  # payment callback page and admin overrides
  def update
    @ts = TeamSeason.find(params[:id])
    if params[:team_season]
      render :status => :forbidden and return unless @current_user && @current_user.is_admin?
      respond_to do |format|
        if @ts.update_attributes(params[:team_season], :as => @current_user.permission_role)
          format.html { redirect_to(manage_season_path(@ts.season_id), :notice => 'TeamSeason was successfully updated.') }
          format.json { respond_with_bip(@ts) }
        else
          format.html { redirect_to(manage_season_path(@ts.season)) }
          format.json { respond_with_bip(@ts) }
        end
      end
    else
      render :status => :forbidden and return unless @current_user && (@current_user.captained_teams.include?(@ts.team) || @current_user.is_admin?)

      #attempt to find them in the Stripe DB first
      if @current_user.stripe_customer_id.nil?
        customer = Stripe::Customer.create(
        :description => @current_user.name,
        :email => @current_user.email,
        :metadata => {:user => @current_user.id, :steam_id => @current_user.steamid},
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
          :team => @ts.team.id,
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
      redirect_to @ts.team
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
    render :status => :forbidden and return unless @current_user && (@current_user.captained_teams.include?(@ts.team) || @current_user.is_admin?)

    title = @ts.season.title
    # TODO: Think about refunds here
    @ts.destroy

    flash[:notice] = "You have withdrawn from " + title
    redirect_to @ts.team
  end
end