class Match < ActiveRecord::Base
  has_many :games, :dependent => :destroy
  has_many :matchcomments, :dependent => :destroy
  belongs_to :home_team, :class_name => "Team"
  belongs_to :away_team, :class_name => "Team"
  belongs_to :season
  has_one :caster, :class_name => "Player"

  # Lambda so it evaluates every call, not just at compile time
  # TODO: This is wrong since date should be UTC or whatever
  scope :future, lambda {where("date > ?", Time.zone.now) }
  scope :scored, where("(home_score IS NOT NULL AND home_score > 0) OR (away_score IS NOT NULL AND away_score > 0)")
  attr_accessible :home_team_id, :away_team_id, :home_score, :away_score, :date, :caster_id, :as => [:admin]

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
end