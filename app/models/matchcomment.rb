class Matchcomment < ActiveRecord::Base
  belongs_to :player, :class_name => "Player"
end
