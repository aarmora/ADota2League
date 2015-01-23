class ChallongeController < ApplicationController
  before_filter :verify_admin
  before_filter :load_season

  # does a full sync of the tournament to challonge
  def setup

    #########
    # update tournament
    #########
    t = @season.challonge_tournament
    t ||= Challonge::Tournament.new
    t.name = "AD2L:" + @season.title
    t.url = "ad2l_dota_#{@season.id}" + (Rails.env.development? ? "_dev" : "")
    t.tournament_type = params[:eliminations].to_i == 2 || (@season.challonge_type && @season.challonge_type == 'double elimination') ? 'double elimination': 'single elimination'
    t.open_signup = false
    t.hold_third_place_match = true
    t.show_rounds = true
    save_successful = t.save
    # if save returns false, view validation errors with t.errors.full_messages

    unless t.state == "pending"
      flash[:error] = "Challonge tournament appears to already be started. Please rebuild if you really want to reset things"
      redirect_to manage_season_path(@season)
      return
    end

    # Write everything back to the database
    @season.challonge_id = t.id
    @season.challonge_url = t.url # just the extension, we'll format this client side
    @season.challonge_type = t.tournament_type
    @season.save!

    #########
    # sync participants
    #########

    # Schema: {"team_id" => team_id}

    # TODO: might want to check that we can actually alter this...but for now, meh (pending)
    participants = t.participants.map { |p| { :challonge_id => p.id, :team_id => team_id_from_player(p) } }

    # If there's no difference, assume we are OK
    db_team_ids = @season.team_seasons.where(:paid => true).where(:checked_in => true).pluck(:team_id)
    participant_team_ids = participants.map{ |p| p[:team_id] }
    synced = db_team_ids & participant_team_ids == db_team_ids && participant_team_ids & db_team_ids == participant_team_ids

    unless synced
      # first remove all participants in Challonge no longer on AD2L
      participants.reject{|p| db_team_ids.include? p[:team_id]}.each do |p|
        t.participants(p[:challonge_id]).destroy
      end

      # next add all participants from AD2L DB not on Challonge, only if not underway
      if t.state == "pending"
        db_ids = db_team_ids.reject{|p| participant_team_ids.include? p}
        teams = Team.find(db_ids).to_a.sort_by{ |t| t.mmr ? t.mmr : t.default_mmr}.reverse
        teams.each_with_index do |team, i|
          Challonge::Participant.create(:name => team.teamname, :tournament => t, :seed => i + 1, :misc => {:team_id => team.id}.to_json)
        end
      end
    end
    flash[:notice] = "Synced to Challonge, updated info below"
    redirect_to manage_season_path(@season)
  end

  def sync_matches
    t = @season.challonge_tournament
    unless t.state == "complete"
      flash[:error] = "Please complete the tournament on Challonge before syncing back to AD2L."
      redirect_to manage_season_path(@season)
      return
    end

    #########
    # remove participants not on challonge
    #########

    participants = t.participants.map { |p| { :challonge_id => p.id, :team_id => team_id_from_player(p) } }
    participant_team_ids = participants.map{ |p| p[:team_id] }

    # Intentionally skip callbacks so we don't refund them or anything. Team Season cannot orphan anything.
    removed_teams_count = TeamSeason.where(:season_id => @season.id).where("team_id NOT IN (:teams)", {:teams => participant_team_ids}).delete_all

    #########
    # sync matches
    #########

    # only sync these to our side from challonge
    db_challonge_match_ids = @season.matches.pluck(:challonge_id)
    challonge_matches = t.matches

    # clear out matches no longer on challonge
    missing_matches = @season.matches.where("challonge_id NOT IN (:match_ids)", {:match_ids => challonge_matches.map{|m| m.id}}).destroy_all

    # sync new ones in
    matches_added = 0
    matches_to_sync = challonge_matches.reject{ |m| db_challonge_match_ids.include? db_challonge_match_ids }.each do |m|
      match = @season.matches.build
      scores = m.scores_csv.split("-") # TODO: this might be wrong
      match.challonge_id = m.id
      match.home_team_id = team_id_from_player(m.player1)
      match.home_score = scores[0] if scores.size == 2
      match.away_team_id = team_id_from_player(m.player2)
      match.away_score = scores[1] if scores.size == 2
      match.save
      matches_added += 1
    end

    flash[:notice] = "Pulled in #{matches_added} matches from Challonge; Removed #{missing_matches.count} stale ones; Removed #{removed_teams_count} teams"
    redirect_to manage_season_path(@season)
  end

  def launch
    if @season.registration_open
      flash[:error] = "You must close registration starting the challonge tournament. Don't forget to sync one more time before starting too!"
      redirect_to manage_season_path(@season)
      return
    end

    t = Challonge::Tournament.find(@season.challonge_id)
    t.start!
    @season.registration_open = false
    @season.active = true
    @season.save!
    expire_fragment("seasonPage-" + @season.id.to_s) unless @season.id.nil?
    flash[:notice] = "All systems go! Good luck!!!"
    redirect_to manage_season_path(@season)
  end

  def rebuild
    t = Challonge::Tournament.find(@season.challonge_id)
    t.reset!
    @season.matches.destroy_all
    setup
  end

  def team_id_from_player(p)
    ActiveSupport::JSON.decode(p.misc)["team_id"]
  end

  def load_season
    @season = Season.find(params[:id])
  end
end