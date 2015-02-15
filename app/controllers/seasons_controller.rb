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
        if @season.team_tourney == true
          #team tourney stuff
          @week_num = params[:week].to_i == 0 ? @season.matches.maximum(:week) : params[:week].to_i

          # we always need the above, only run all the queries if we need to rebuild the cache or it's an admin or users need to see their individual check in
          @no_cache = Permissions.can_view?(@season) || @season.check_in_available?
          if @no_cache || !fragment_exist?("seasonPage-" + params[:id].to_s)

            # Cue the permission system to load the divisions if we might need those
            Permissions.match_captain_permissions_off
            Permissions.load_team_divisions_for_season(@season.id) unless Permissions.can_edit?(@season) || !Permissions.can_view?(@season)

            @matches = @season.matches.includes(:home_participant, :away_participant, :caster).to_a.sort_by{|m| m.date ? m.date : Time.now}.reverse
            @casters = Player.where(:caster => true)
            @permissions = Permission.includes(:player).all

            @teams_by_division = @season.team_seasons.includes(:participant).where(:paid => true).group_by {|ts| ts.division.to_s}

            # compute the scores using the pieces we already have so we don't need to re-fetch them again
            # NOTE: Relys on one participant_type per season
            if params[:id] == "1"
              # don't display the divisions here
              @teams_by_division = {"" => @teams_by_division.collect {|div, teams| teams}.flatten}
              @total_scores = {}
              @matches.each do |match|
                @total_scores[match.home_participant_class_id] = @total_scores[match.home_participant_class_id].to_i + match.home_score.to_i
                @total_scores[match.away_participant_class_id] = @total_scores[match.away_participant_class_id].to_i + match.away_score.to_i
              end
            elsif params[:id] != "6"
              #display divisions here
              @total_scores = {}
              @matches.each do |match|
                @total_scores[match.home_participant_class_id] = @total_scores[match.home_participant_class_id].to_i + match.home_score.to_i
                @total_scores[match.away_participant_class_id] = @total_scores[match.away_participant_class_id].to_i + match.away_score.to_i
              end
            else
              @total_scores = {}
              @matches.each do |match|
                @total_scores[match.home_participant_class_id] = @total_scores[match.home_participant_class_id].to_i + (match.home_score.to_i == 2 ? 1 : 0)
                @total_scores[match.away_participant_class_id] = @total_scores[match.away_participant_class_id].to_i + (match.away_score.to_i == 2 ? 1 : 0)
              end
            end
          end
        else
          #solo tourney stuff          
          @teams_by_division = @season.team_seasons.includes(:participant).where(:paid => true).group_by {|ts| ts.division.to_s}

          @solo_league_matches = SoloLeagueMatch.where(:season_id => @season.id).includes(:home_player_1, :home_player_2, :home_player_3, :home_player_4, :home_player_5, :away_player_1, :away_player_2, :away_player_3, :away_player_4, :away_player_5)
          @total_wins = {}
          @total_losses = {}
          @solo_league_matches.each do |match|
            if match.home_wins == true
              puts "home_wins"
              puts match.home_team_id_1
              #Add home win
              @total_wins[match.home_team_id_1] = @total_wins[match.home_team_id_1].to_i + 1
              @total_wins[match.home_team_id_2] = @total_wins[match.home_team_id_2].to_i + 1
              @total_wins[match.home_team_id_3] = @total_wins[match.home_team_id_3].to_i + 1
              @total_wins[match.home_team_id_4] = @total_wins[match.home_team_id_4].to_i + 1
              @total_wins[match.home_team_id_5] = @total_wins[match.home_team_id_5].to_i + 1

              #Add away loss
              @total_losses[match.away_team_id1] = @total_losses[match.away_team_id1].to_i + 1
              @total_losses[match.away_team_id2] = @total_losses[match.away_team_id2].to_i + 1
              @total_losses[match.away_team_id3] = @total_losses[match.away_team_id3].to_i + 1
              @total_losses[match.away_team_id4] = @total_losses[match.away_team_id4].to_i + 1
              @total_losses[match.away_team_id5] = @total_losses[match.away_team_id5].to_i + 1
            elsif match.home_wins == false
              puts "away_loses"
              #Add away win
              @total_wins[match.away_team_id1] = @total_wins[match.away_team_id1].to_i + 1
              @total_wins[match.away_team_id2] = @total_wins[match.away_team_id2].to_i + 1
              @total_wins[match.away_team_id3] = @total_wins[match.away_team_id3].to_i + 1
              @total_wins[match.away_team_id4] = @total_wins[match.away_team_id4].to_i + 1
              @total_wins[match.away_team_id5] = @total_wins[match.away_team_id5].to_i + 1

              #Add home loss
              @total_losses[match.home_team_id_1] = @total_losses[match.home_team_id_1].to_i + 1
              @total_losses[match.home_team_id_2] = @total_losses[match.home_team_id_2].to_i + 1
              @total_losses[match.home_team_id_3] = @total_losses[match.home_team_id_3].to_i + 1
              @total_losses[match.home_team_id_4] = @total_losses[match.home_team_id_4].to_i + 1
              @total_losses[match.home_team_id_5] = @total_losses[match.home_team_id_5].to_i + 1
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
    @season = Season.find(params[:id])
    if @season.team_seasons.first.is_a? Team
      @season = Season.includes({:team_seasons => [:participant => [:captain]], :matches => [:away_team, :home_team]}).find(params[:id])
      @player_season = false
    else
      @player_season = true
    end
    head :forbidden and return unless Permissions.can_view?(@season)

    @players = Player.order("name ASC").pluck(:id, :name)
  end

  def reg_form_partial
    @team = Team.find(params[:team_id])

    render :partial => "seasons/registration_form", :locals => {:participant => @team}
  end

end
