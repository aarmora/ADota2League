class SeasonsController < ApplicationController
  def index
  	# TODO: this is a hack, set it explicitly to prevent the DB call here
    params[:id] = "2"
    show
  end
  def show
    @seasons = Season.all
    @season = @seasons.detect {|season| season.id == params[:id].to_i}
    unless fragment_exist?("seasonPage-" + params[:id].to_s)
      @teams = @season.teams # TODO: optimize dual lookup with below?
      @matches = @season.matches.includes(:home_team, :away_team)
      @casters = Player.where(:caster => true)

      @teams_by_division = @season.team_seasons.where("division IS NOT NULL").group_by(&:division)

      # compute the scores using the pieces we already have so we don't need to re-fetch them again
      if params[:id] == "1"
        # don't display the divisions here
        @teams_by_division = {"" => @teams_by_division.collect {|div, teams| teams}.flatten}
        @total_scores = {}
        @matches.each do |match|
          @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + match.home_score.to_i
          @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + match.away_score.to_i
        end
      elsif params[:id] == "2"
        @total_scores = {}
        @matches.each do |match|
          @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + (match.home_score.to_i == 2 ? 1 : 0)
          @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + (match.away_score.to_i == 2 ? 1 : 0)
        end
      end

      # @teams.sort_by!{|t| [@total_scores[t.id].to_i * -1, t.teamname]}
      @matches.sort_by!{|m| m.date ? m.date : Time.now}.reverse
    end

    @current_tab = 'seasons'

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end

end
