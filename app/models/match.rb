class Match < ActiveRecord::Base
  has_many :games, :dependent => :destroy
  has_many :matchcomments, :dependent => :destroy
  belongs_to :home_participant, polymorphic: true
  belongs_to :away_participant, polymorphic: true
  belongs_to :season
  belongs_to :caster, :class_name => "Player"

  # Lambda so it evaluates every call, not just at compile time
  # TODO: This is wrong since date should be UTC or whatever
  scope :future, -> {where "date > ?", Time.zone.now }
  scope :scored, -> {where "(home_score IS NOT NULL AND home_score > 0) OR (away_score IS NOT NULL AND away_score > 0)"}
  attr_accessible :home_score, :away_score, :caster_id, :forfeit, :date, :reschedule_time, :as => [:admin, :captain]
  attr_accessible :home_participant_id, :away_participant_id, :lobby_password, :week, :season_id, :as => :admin

  # We could use a uniqueness validator, but since we have home and away, it wouldn't work so well
  validates_each :home_participant, :away_participant do |record, attr, value|
    home_query = Match.where(home_participant: value).where_values.reduce(:and)
    away_query = Match.where(away_participant: value).where_values.reduce(:and)
    if Match.where(season_id: record.season_id, week: record.week).where(home_query.or(away_query)).where.not(id: record.id).exists?
      record.errors.add(attr, 'cannot play more than one match per week/round')
    end
    if !TeamSeason.where(season_id: record.season_id, participant: value).exists?
      record.errors.add(attr, 'does not appear to be registered for this match\'s season')
    end
  end

  # TODO: This might break migrations, enable once live
  # validates :date, :week, :season, :presence => true

  # class_id is used to identify the type and id so as not to confuse players and teams with the same actual id
  def home_participant_class_id
    "#{home_participant_type}/#{home_participant_id}"
  end
  def away_participant_class_id
    "#{away_participant_type}/#{away_participant_id}"
  end

  # in the DB, these can be nil, which sort of sucks...so let's fix that
  def home_score
    super.to_i
  end
  def away_score
    super.to_i
  end

  # Used by tournament code to slot a new participant in when the previous game ends
  def add_participant(participant)
    # Assume we are in a tournament, we'll want to look at the seeds and slot the higher seed as home
    self.logger.info("Adding #{participant.name} to match ##{self.id}")
    self.logger.error("Cannot add participants when match has scores already") and raise if self.home_score > 0 || self.away_score > 0
    self.logger.error("Cannot add participants; no free slots in match") and raise if self.home_participant && self.away_participant

    current_participant = self.home_participant || self.away_participant
    current_seed = current_participant ? TeamSeason.where(participant: current_participant, season_id: self.season_id).first.division : nil
    participant_seed = TeamSeason.where(participant: participant, season_id: self.season_id).first.division
    if !current_seed || participant_seed > current_seed
      self.home_participant = participant
      self.away_participant = current_participant
    else
      self.home_participant = current_participant
      self.away_participant = participant
    end
    self.save!
  end

  # Used by tournament code to slot a new participant in when the previous game ends
  def remove_participants(*participants)
    participants = participants.flatten
    self.logger.error("Cannot remove participants when match has scores already") and raise if self.home_score > 0 || self.away_score > 0

    self.home_participant = nil if participants.include? self.home_participant
    self.away_participant = nil if participants.include? self.away_participant
    self.save!
  end

  # Called to update the match score from the associated games
  def update_score_from_games!
    return if self.games.count == 0
    score_by_steam_id = {}
    self.games.each do |g|
      # Add one point to winning team, 0 to losing team so that they show up in the keyset when we check later
      if g.radiant_win === true
        score_by_steam_id[g.radiant_team_id] = score_by_steam_id[g.radiant_team_id].to_i + 1
        score_by_steam_id[g.dire_team_id] = score_by_steam_id[g.dire_team_id].to_i
      elsif g.radiant_win === false
        score_by_steam_id[g.radiant_team_id] = score_by_steam_id[g.radiant_team_id].to_i
        score_by_steam_id[g.dire_team_id] = score_by_steam_id[g.dire_team_id].to_i + 1
      end
    end

    # OK the keys are team ids, so now save them
    if score_by_steam_id[self.home_participant.id] != nil && score_by_steam_id[self.away_participant.id] != nil
      self.home_score = score_by_steam_id[self.home_participant.id]
      self.away_score = score_by_steam_id[self.away_participant.id]
      self.save!
    else
      puts score_by_steam_id.inspect
      puts self.home_participant_id.inspect
      puts self.away_participant_id.inspect
      puts "WARNING: teams did not match, not updating match score"
    end
  end

  def create_auto_match_comments(changes, user)
    # check type conversions since this is coming off params :-/
    changes.each  {|field, vals| vals[1] = vals[1].to_i if vals[1].to_i.to_s == vals[1]}
    return true unless changes.any? {|field, vals| vals[0] != vals[1]}

    text = "The following changes were made:<br />"
    changes.each do |field, vals|
      text += "#{field}: #{vals[0]} -> #{vals[1]}<br />"
    end
    comment = self.matchcomments.build(:player_id => user.id, :comment => text)
    comment.auto_generated = true
    comment.save!
  end
end