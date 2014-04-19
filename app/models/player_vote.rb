class PlayerVote < ActiveRecord::Base
  belongs_to :endorser, :class_name => "Player"
  belongs_to :player, :counter_cache => :endorsements_count, :foreign_key => "recipient_id"
end