class SeasonsController < ApplicationController
  def index
    params[:id] = Season.first.id
    show
  end
  def show
    @season = Season.find(params[:id])
    @teams = @season.teams
    @matches = @season.matches

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end
end
