class SeasonsController < ApplicationController
  def index
  	# TODO: this is a hack, set it explicitly to prevent the DB call here
    params[:id] = "2"
    show
  end
  def show
    @seasons = Season.all
    @season = @seasons.detect {|season| season.id == params[:id].to_i}
    @week_num = params[:week].to_i == 0 ? @season.matches.maximum(:week) : params[:week].to_i

    # we always need the above, only run all the queries if we need to rebuild the cache or it's an admin
    if (@current_user && @current_user.is_admin?) || !fragment_exist?("seasonPage-" + params[:id].to_s + "-" + @week_num.to_s)
      @matches = @season.matches.includes(:home_team, :away_team, :caster)
      @casters = Player.where(:caster => true)

      @teams_by_division = @season.team_seasons.includes(:team).where("division IS NOT NULL").group_by(&:division)

      # compute the scores using the pieces we already have so we don't need to re-fetch them again
      if params[:id] == "1"
        # don't display the divisions here
        @teams_by_division = {"" => @teams_by_division.collect {|div, teams| teams}.flatten}
        @total_scores = {}
        @matches.each do |match|
          @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + match.home_score.to_i
          @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + match.away_score.to_i
        end
        #Week has to be adjusted after scores are calculated
        @matches = @season.matches.includes(:home_team, :away_team, :caster).where("week > 5").sort_by!{|m| m.date ? m.date : Time.now}.reverse
      elsif params[:id] == "2"
        @total_scores = {}
        @matches.each do |match|
          @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + (match.home_score.to_i == 2 ? 1 : 0)
          @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + (match.away_score.to_i == 2 ? 1 : 0)
        #Less weeks in invitational
        @matches = @season.matches.includes(:home_team, :away_team, :caster).sort_by!{|m| m.date ? m.date : Time.now}.reverse
        end
      end

      # @teams.sort_by!{|t| [@total_scores[t.id].to_i * -1, t.teamname]}
    end

    @current_tab = 'seasons'

    render :action => 'show' # explicitly needed because index calls this method and expects it to render
  end

end
