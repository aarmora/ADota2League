class Game < ActiveRecord::Base
  belongs_to :match
  attr_accessible :steam_match_id, :dire_team_id, :dire_team_name, :radiant_team_id, :radiant_team_name, :radiantwin
  
  # TODO: Update the score of the associated match (needs create and update callbacks?)
end
