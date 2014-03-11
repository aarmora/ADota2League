class SeasonsController < ApplicationController
  def index
  	# TODO: this is a hack, set it explicitly to prevent the DB call here
    params[:id] = Season.first.id
    show    
  end
  def show
    @seasons = Season.all
    @season = @seasons.detect {|season| season.id == params[:id].to_i}
    @teams = @season.teams # TODO: optimize dual lookup with below?
    @matches = @season.matches.includes(:home_team, :away_team)
    @current_tab = 'seasons'

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end
end
