class AddCounterCacheToPlayerEndorsements < ActiveRecord::Migration
  def up
    add_column :players, :endorsements_count, :integer, :default => 0, :null => false
    Player.reset_column_information
    PlayerVote.all.group_by(&:player).each do |player, votes|
      player.endorsements_count = votes.size
      player.save!
    end
  end

  def down
    remove_column :players, :endorsements_count
  end
end
