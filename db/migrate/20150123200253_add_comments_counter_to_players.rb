class AddCommentsCounterToPlayers < ActiveRecord::Migration
  def up
    add_column :players, :comments_count, :integer, :default => 0, :null => false
    Player.reset_column_information
    PlayerComment.group(:recipient_id).count.each do |player, num_comments|
      Player.reset_counters player, :player_comments
    end
  end

  def down
    remove_column :players, :comments_count
  end
end
