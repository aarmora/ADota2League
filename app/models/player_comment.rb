class PlayerComment < ActiveRecord::Base
  belongs_to :commenter, :class_name => "Player"
  attr_accessible :commenter_id, :recipient_id, :comment
  belongs_to :player, :counter_cache => :comments_count, :foreign_key => "recipient_id"
end