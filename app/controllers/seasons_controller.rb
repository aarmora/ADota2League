class SeasonsController < ApplicationController
  before_filter :verify_admin, :only => [:create, :update, :manage]

  def index
  	# TODO: this is a hack, set it explicitly to prevent the DB call here
    params[:id] = Season.where(:active => true).first.id
    show
  end

  def show

      @seasons = Season.all
      @season = @seasons.detect {|season| season.id == params[:id].to_i}
      if @season.nil?
        redirect_to seasons_path
      else
        @week_num = params[:week].to_i == 0 ? @season.matches.maximum(:week) : params[:week].to_i

        # we always need the above, only run all the queries if we need to rebuild the cache or it's an admin or users need to see their individual check in
        @no_cache = Permissions.can_view?(@season) || @season.check_in_available?
        if @no_cache || !fragment_exist?("seasonPage-" + params[:id].to_s)

          # Cue the permission system to load the divisions if we might need those
          Permissions.load_team_divisions_for_season(@season.id) unless Permissions.can_edit?(@season) || !Permissions.can_view?(@season)

          @matches = @season.matches.includes(:home_team, :away_team, :caster).sort_by!{|m| m.date ? m.date : Time.now}.reverse
          @casters = Player.where(:caster => true)
          @permissions = Permission.includes(:player).all

          @teams_by_division = @season.team_seasons.includes(:team).group_by {|ts| ts.division.to_s}

          # compute the scores using the pieces we already have so we don't need to re-fetch them again
          if params[:id] == "1"
            # don't display the divisions here
            @teams_by_division = {"" => @teams_by_division.collect {|div, teams| teams}.flatten}
            @total_scores = {}
            @matches.each do |match|
              @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + match.home_score.to_i
              @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + match.away_score.to_i
            end
          elsif params[:id] == "8" || params[:id] == "9"
            #display divisions herr
            @total_scores = {}
            @matches.each do |match|
              @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + match.home_score.to_i
              @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + match.away_score.to_i
            end
          else
            @total_scores = {}
            @matches.each do |match|
              @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + (match.home_score.to_i == 2 ? 1 : 0)
              @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + (match.away_score.to_i == 2 ? 1 : 0)
            end
          end
        end

        @current_tab = 'seasons'

        render :action => 'show' # explicitly needed because index calls this method and expects it to render
      end
  end

  def create
    s = Season.create
    redirect_to manage_season_path(s)
  end

  def update
    @season = Season.find(params[:id])
    head :forbidden and return unless Permissions.can_edit? @season
    respond_to do |format|
      if @season.update_attributes(params[:season], :as => @current_user.role_for_object(@season))
        expire_fragment("seasonPage-" + @season.id.to_s)
        format.html { redirect_to(@season, :notice => 'Season was successfully updated.') }
        format.json { respond_with_bip(@season) }
      else
        format.html { render :action => "show" }
        format.json { respond_with_bip(@season) }
      end
    end
  end

  def manage
    # custom permissions for this one
    @season = Season.includes({:team_seasons => [:team => [:captain]], :matches => [:away_team, :home_team]}).find(params[:id])
    head :forbidden and return unless Permissions.can_view?(@season)

    @players = Player.order("name ASC").pluck_all(:id, :name)
  end
end
