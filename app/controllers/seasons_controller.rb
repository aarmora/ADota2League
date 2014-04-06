class SeasonsController < ApplicationController
  def index
  	# TODO: this is a hack, set it explicitly to prevent the DB call here
    params[:id] = "2"
    show
  end
  def show
    @seasons = Season.all
    @season = @seasons.detect {|season| season.id == params[:id].to_i}
    @teams = @season.teams # TODO: optimize dual lookup with below?
    @matches = @season.matches.includes(:home_team, :away_team)
    @casters = Player.where(:caster => true)

    # TODO: This should really be on the team season record, change it there and remove this
    # @division_names = {"1" => "Not quite Gallifrey", "2" => "Careless Whisper", "3" => "Take off, you hoser", "4" => "California Love"]

    # I'm sure there's a way I could do this better
    @teams_by_division = @season.team_seasons.where("division IS NOT NULL").group_by(&:division)

    # compute the scores using the pieces we already have so we don't need to re-fetch them again
    if params[:id] == "1"
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

    @teams.sort_by!{|t| [@total_scores[t.id].to_i * -1, t.teamname]}
    @matches.sort_by!{|m| m.date ? m.date : Time.now}.reverse

    @current_tab = 'seasons'

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end

end
