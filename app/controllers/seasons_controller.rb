class SeasonsController < ApplicationController
  before_filter :verify_admin, :except => [:index, :show]

  def index
  	# TODO: this is a hack, set it explicitly to prevent the DB call here
    season = Season.where(:active => true).first
    params[:id] = season.id if season
    if season
      show
    else
      redirect_to root_path
    end
  end

  def destroy
    @season = Season.find(params[:id])
    head :forbidden and return unless Permissions.can_edit? @season
    @season.destroy
    redirect_to admin_index_path
  end

  def getRound(node)
    return 0 if !node.left && !node.right
    return getRound(node.left) + 1
  end

  def show
    @current_tab = 'seasons'
    @season = Season.find_by(id: params[:id])

    respond_to do |format|
        format.json { render :json => @season }
        format.html do
          if @season.nil?
            redirect_to seasons_path and return
          end

          # Check if it's a tournament or round robin for determining what to render
          if @season.round_robin? || !@season.tournament_started?
            @week_num = params[:week].to_i == 0 ? @season.matches.maximum(:week) : params[:week].to_i

            # we always need the above, only run all the queries if we need to rebuild the cache or it's an admin or users need to see their individual check in
            @no_cache = Permissions.can_view?(@season) || @season.check_in_available?
            if @no_cache || !fragment_exist?("seasonPage-" + params[:id].to_s)
              # Cue the permission system to load the divisions if we might need those
              Permissions.match_captain_permissions_off
              Permissions.load_team_divisions_for_season(@season.id) unless Permissions.can_edit?(@season) || !Permissions.can_view?(@season)
              generate_season_data

              # Tournaments hijack the division field for seedings, so don't use it
              @teams_by_division = {foo: @teams_by_division.values.flatten } unless @season.round_robin?
            end
            render :action => 'show' # explicitly needed because index calls this method and expects it to render
          else
            if @season.single_elim?
              @brackets = [@season.matches.includes(:home_participant, :away_participant, :caster).group_by(&:week)]
            elsif @season.double_elim?
              matches = @season.matches.includes(:home_participant, :away_participant, :caster)
              loser_bracket, winner_bracket = matches.partition { |m| !m.winner_match_id.nil? && m.loser_match_id.nil? }
              @brackets = [winner_bracket.group_by(&:week), loser_bracket.group_by(&:week)]
            end


            # deal with grouping by loser / winner bracket
            render "seasons/show_playoff"
          end
        end
    end
  end

  def generate_season_data # Requires @season
    @matches = @season.matches.includes(:home_participant, :away_participant, :caster).to_a.sort_by{|m| m.date ? m.date : Time.now}.reverse
    @casters = Player.where(:caster => true)
    @permissions = Permission.includes(:player).all

    @team_seasons = @season.team_seasons.includes(:participant).where(:paid => true)
    @teams_by_division = @team_seasons.group_by {|ts| ts.division.to_s}

    # compute the scores using the pieces we already have so we don't need to re-fetch them again
    # NOTE: Relies on one participant_type per season
    # if params[:id] == "1"
    #   # don't display the divisions here
    #   @teams_by_division = {"" => @teams_by_division.collect {|div, teams| teams}.flatten}
    #   @total_scores = {}
    #   @matches.each do |match|
    #     @total_scores[match.home_participant_class_id] = @total_scores[match.home_participant_class_id].to_i + match.home_score.to_i
    #     @total_scores[match.away_participant_class_id] = @total_scores[match.away_participant_class_id].to_i + match.away_score.to_i
    #   end
    # elsif params[:id] != "6"
      #display divisions here
      @total_scores = {}
      @matches.each do |match|
        @total_scores[match.home_participant_class_id] = @total_scores[match.home_participant_class_id].to_i + match.home_score.to_i
        @total_scores[match.away_participant_class_id] = @total_scores[match.away_participant_class_id].to_i + match.away_score.to_i
      end
    # else
    #   @total_scores = {}
    #   @matches.each do |match|
    #     @total_scores[match.home_participant_class_id] = @total_scores[match.home_participant_class_id].to_i + (match.home_score.to_i == 2 ? 1 : 0)
    #     @total_scores[match.away_participant_class_id] = @total_scores[match.away_participant_class_id].to_i + (match.away_score.to_i == 2 ? 1 : 0)
    #   end
    # end
  end

  def create
    s = Season.create
    redirect_to manage_season_path(s)
  end

  def update
    @season = Season.find(params[:id])
    head :forbidden and return unless Permissions.can_edit? @season
    respond_to do |format|
      if @season.update_attributes(season_params)
        expire_fragment("seasonPage-" + @season.id.to_s)
        format.html { redirect_to(@season, :notice => 'Season was successfully updated.') }
        format.json { respond_with_bip(@season) }
      else
        format.html { render :action => "show" }
        format.json { respond_with_bip(@season) }
      end
    end
  end

  #
  # TODO: Admin stuff that totally doesn't belong here
  #

  def manage
    # custom permissions for this one
    @season = Season.find(params[:id])

    s = Season.includes(:matches => [:home_participant, :away_participant])
    if @season.team_tourney
      s = s.includes({:team_seasons => [:participant => [:captain]]})
    else
      s = s.includes(:team_seasons => :participant)
    end
    @season = s.find(params[:id])

    head :forbidden and return unless Permissions.can_view?(@season)

    @players_query = Player.order("name ASC")
  end

  def playoffs
    @season = Season.find(params[:id])
    head :not_found and return unless @season.round_robin?
    head :forbidden and return unless Permissions.can_edit?(@season)
    generate_season_data
    @start_date = Date.today + 2
    @start_date += 1 + (3 - @start_date.wday) % 7
  end

  def start_playoffs # GET
    @season = Season.find(params[:id])
    head :not_found and return if @season.round_robin?
    head :forbidden and return unless Permissions.can_edit?(@season)

    @season.setup_tournament_matches
    redirect_to @season
  end

  def reset_playoffs # GET
    @season = Season.find(params[:id])
    head :not_found and return if @season.round_robin?
    head :forbidden and return unless Permissions.can_edit?(@season)

    @season.matches.destroy_all
    redirect_to @season
  end

  def create_playoffs # POST
    @season = Season.find(params[:id])
    head :not_found and return unless @season.round_robin?
    head :forbidden and return unless Permissions.can_edit?(@season)

    playoff_season = Season.new
    playoff_season.title = @season.title + " Playoffs"
    playoff_season.start_date = Time.now
    playoff_season.active = true
    playoff_season.team_tourney = @season.team_tourney
    playoff_season.season_type = params[:season_type]
    playoff_season.save!

    params[:participants].sort_by {|k,v| v.to_i}.first(params[:size].to_i).each do |id, seed|
      ts = playoff_season.team_seasons.new
      ts.paid = true
      ts.division = seed
      ts.checked_in = true
      if playoff_season.team_tourney
        ts.participant = Team.find(id)
      else
        ts.participant = Player.find(id)
      end
      ts.save!
    end

    start_date = Date.strptime(params[:start_date], "%m/%d/%Y")
    playoff_season.setup_tournament_matches(start_date, params[:utc_offset])

    if params[:deactivate].to_i == 1
      @season.active = false
      @season.save
    end

    redirect_to playoff_season
  end

  private

  def season_params
    if @current_user.role_for_object(@season) == :admin
      params.require(:season).permit(:title, :league_id, :registration_open, :active, :late_fee_start, :price_cents, :late_price_cents, :exclusive_group, :start_date, :challonge_url, :description, :team_tourney, :season_type, :rules)
    end
  end

end
