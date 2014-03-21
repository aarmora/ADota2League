class Team < ActiveRecord::Base
  has_and_belongs_to_many :players
  has_many :home_matches, :class_name => 'Match', :foreign_key => "home_team_id"
  has_many :away_matches, :class_name => 'Match', :foreign_key => "away_team_id"
  has_one :captain, :class_name => "Player"
  has_many :team_seasons, :dependent => :delete_all
  
  attr_accessible :teamname, :as => [:default, :admin]
  attr_accessible :region, :dotabuff_id, :captain_id, :mmr, :originalmmr, :as => :admin

  # Note: this will probably be read only
  def matches
     home_matches + away_matches
  end
end
