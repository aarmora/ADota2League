class Permission < ActiveRecord::Base
  belongs_to :player, :class_name => "Player"
  belongs_to :season, :class_name => "Season"
  attr_accessible :player_id, :permission_mode, :organization_id, :season_id, :division
end