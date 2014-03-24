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

    # compute the scores using the pieces we already have so we don't need to re-fetch them again
    @total_scores = {}
    @matches.each do |match|
      @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + match.home_score.to_i
      @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + match.away_score.to_i
    end

    @teams.sort_by!{|t| [@total_scores[t.id].to_i * -1, t.teamname]}
    @matches.sort_by!(&:date).reverse

    @current_tab = 'seasons'

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end
end
