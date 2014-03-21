class Match < ActiveRecord::Base
  has_many :games, :dependent => :destroy
  belongs_to :home_team, :class_name => "Team"
  belongs_to :away_team, :class_name => "Team"
  belongs_to :season
  
  # Lambda so it evaluates every call, not just at compile time
  # TODO: This is wrong since date should be UTC or whatever
  scope :future, lambda {where("date > ?", Time.zone.now) }
end
