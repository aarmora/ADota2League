class ChallongeController < ApplicationController
  before_filter :verify_admin
  before_filter :load_season

  # does a full sync of the tournament to challonge
  def setup
    if @season.registration_open
      flash[:error] = "You must close registration before setting up the challonge tournament"
      redirect_to manage_season_path(@season)
    end

    #########
    # update tournament
    #########
    t = Challonge::Tournament.find(@season.challonge_id) if @season.challonge_id
    t ||= Challonge::Tournament.new
    t.name = "AD2L:" + @season.title
    t.url = "ad2l_dota_#{@season.id}"
    t.tournament_type = params[:eliminations].to_i == 2 || (@season.challonge_type && @season.challonge_type == 'double elimination') ? 'double elimination': 'single elimination'
    t.open_signup = false
    t.hold_third_place_match = true
    save_successful = t.save
    # if save returns false, view validation errors with t.errors.full_messages

    #########
    # sync participants
    #########

    # Schema: {"team_id" => team_id}

    # TODO: might want to check that we can actually alter this...but for now, meh (pending)
    participants = t.participants.map { |p| { :challonge_id => p.id, :team_id => team_id_from_player(p) }

    # If there's no difference, assume we are OK
    db_team_ids = @season.team_seasons.pluck(:team_id)
    synced = db_team_ids & participants.map(&:team_id) == db_team_ids && participants.map(&:team_id) & db_team_ids == participants.map(&:team_id)

    unless synced
      # first remove all participants in Challonge no longer on AD2L
      participants.reject{|p| db_team_ids.include? p[:team_id]}.each do |p|
        t.participants(p[:challonge_id]).destroy
      end

      # next add all participants from AD2L DB not on Challonge
      if t.state == "pending"
        db_team_ids.reject{|p| participants.map(&:team_id).include? p[:team_id]}.each do |db_team_id|
          team = Team.find(db_team_id)
          Challonge::Participant.create(:name => team.teamname, :tournament => t, :misc => {:team_id => team.id}.to_json)
        end
      end
    end

    # Write everything back to the database
    @season.challonge_id = t.id
    @season.challonge_url = t.url # just the extension, we'll format this client side
    @season.challonge_type = t.tournament_type
    @season.save!
  end

  def sync_matches
    t = Challonge::Tournament.find(@season.challonge_id)
    #########
    # sync matches
    #########

    # only sync these to our side from challonge
    db_challonge_match_ids = @season.matches.pluck(:challonge_id)
    challonge_matches = t.matches

    # clear out matches no longer on challonge
    missing_matches = @season.matches.where("challonge_id NOT IN (:match_ids)", {:match_ids => challonge_matches.map{|m| m.id}}).destroy_all

    # sync new ones in
    matches_to_sync = challonge_matches.reject{ |m| db_challonge_match_ids.include? db_challonge_match_ids }.each do |m|
      match = @season.matches.build(:challonge_id => m.id)
      scores = m.scores_csv.split("-") # TODO: this might be wrong
      match.home_team_id = team_id_from_player(m.player1)
      match.home_score = scores[0] if scores.size == 2
      match.away_team_id = team_id_from_player(m.player2)
      match.away_score = scores[1] if scores.size == 2
      match.save
    end
  end

  def team_id_from_player(p)
    ActiveSupport::JSON.decode(p.misc)["team_id"]
  end

  def load_season
    @season = Season.find(params[:id])
  end
end