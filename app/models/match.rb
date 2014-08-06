class Match < ActiveRecord::Base
  has_many :games, :dependent => :destroy
  has_many :matchcomments, :dependent => :destroy
  belongs_to :home_team, :class_name => "Team"
  belongs_to :away_team, :class_name => "Team"
  belongs_to :season
  belongs_to :caster, :class_name => "Player"

  # Lambda so it evaluates every call, not just at compile time
  # TODO: This is wrong since date should be UTC or whatever
  scope :future, lambda {where("date > ?", Time.zone.now) }
  scope :scored, where("(home_score IS NOT NULL AND home_score > 0) OR (away_score IS NOT NULL AND away_score > 0)")
  attr_accessible :home_team_id, :away_team_id, :date, :lobby_password, :as => [:admin]
  attr_accessible :home_score, :away_score, :caster_id, :forfeit, :date, :as => [:admin, :captain]

  # We could use a uniqueness validator, but since we have home and away, it wouldn't work so well
  validates_each :home_team_id, :away_team_id do |record, attr, value|
    if Match.where("id != :match AND season_id = :season AND week = :week AND (home_team_id = :id OR away_team_id = :id)", {:id => value, :match => record.id, :season => record.season_id, :week => record.week}).count > 0
      record.errors.add(attr, 'cannot play more than one match per week')
    end
  end

  # TODO: This might break migrations, enable once live
  # validates :date, :week, :season, :presence => true

  # in the DB, these can be nil, which sort of sucks...so let's fix that
  def home_score
    super.to_i
  end

  def away_score
    super.to_i
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
    if score_by_steam_id[self.home_team.id] != nil && score_by_steam_id[self.away_team.id] != nil
      self.home_score = score_by_steam_id[self.home_team.id]
      self.away_score = score_by_steam_id[self.away_team.id]
      self.save!
    else
      puts score_by_steam_id.inspect
      puts self.home_team_id.inspect
      puts self.away_team_id.inspect
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