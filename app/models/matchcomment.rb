class Matchcomment < ActiveRecord::Base
  belongs_to :match
  attr_accessible :match_id, :player_id, :comment
  
  # TODO: Update the score of the associated match (needs create and update callbacks?)
end
