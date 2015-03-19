class PlayerComment < ActiveRecord::Base
  belongs_to :commenter, :class_name => "Player"
  belongs_to :player, :counter_cache => :comments_count, :foreign_key => "recipient_id"
end