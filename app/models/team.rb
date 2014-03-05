class Team < ActiveRecord::Base
  has_and_belongs_to_many :players
  has_many :home_matches, :class_name => 'Match', :foreign_key => "home_team_id"
  has_many :away_matches, :class_name => 'Match', :foreign_key => "away_team_id"
  has_one :captain, :class_name => "Player"

  # Note: this will probably be read only
  def matches
     home_matches + away_matches
  end
  # attr_accessible :title, :body
end
