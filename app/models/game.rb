class Game < ActiveRecord::Base
  belongs_to :match

  # TODO: Needs fixing / removing
  # attr_accessible :steam_match_id, :dire_dota_team_id, :dire_team_name, :radiant_dota_team_id, :radiant_team_name, :radiant_win

  # TODO: Update the score of the associated match (needs create and update callbacks?)
end
