class Permission < ActiveRecord::Base
  belongs_to :player, :class_name => "Player"
  attr_accessible :player_id, :permission_mode, :organization_id, :season_id, :division, :as => :admin
end