class SeasonsController < ApplicationController
  def index
    params[:id] = Season.first.id
    show    
  end
  def show
    @season = Season.find(params[:id])
    @teams = @season.teams
    @matches = @season.matches
    @current_tab = 'seasons'
    @matches_refined = Match.includes(:home_team, :away_team).select{ |match| match.away_team && match.home_team && match.away_team.season && match.home_team.season}

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end
end
