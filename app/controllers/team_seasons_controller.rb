class TeamSeasonsController < ApplicationController

  def create
    @team = Team.find(params[:team_season][:team_id])
    render :status => :forbidden and return unless @current_user && (@current_user.captained_teams.include?(@team) || @current_user.is_admin?)

    #verify this is OK again
    @season = Season.find(params[:team_season][:season_id])
    raise unless @team.seasons_available_for_registration.include? @season

    @ts = @season.team_seasons.build
    @ts.team = @team
    @ts.price_paid_cents = @season.current_price
    @ts.paid = true if @season.current_price == 0
    @ts.save!

    if @season.current_price == 0
      flash[:notice] = "You have been registered for " + @season.title
      redirect_to @team
    else
      # redirect to payment for this season path
    end
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