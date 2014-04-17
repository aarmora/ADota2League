class RemoveTimestampsFromPlayerVotes < ActiveRecord::Migration
  def change
  	remove_column :player_votes, :created_at
  	remove_column :player_votes, :updated_at
  end
end
