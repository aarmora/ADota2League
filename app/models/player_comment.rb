class PlayerComment < ActiveRecord::Base
  belongs_to :commenter, :class_name => "Player"
  attr_accessible :commenter_id, :recipient_id, :comment
end