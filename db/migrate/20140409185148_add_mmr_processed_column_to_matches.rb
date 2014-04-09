class AddMmrProcessedColumnToMatches < ActiveRecord::Migration
  def up
    add_column :matches, :mmr_processed, :boolean, :default => false, :null => false
    Team.where(:active => nil).update_all(:active => false)
    change_column :teams, :active, :boolean, :default => true, :null => false
    Match.reset_column_information
    Match.update_all(:mmr_processed => true)
    # Team.where(:active => nil)
  end

  def down
    remove_column :matches, :mmr_processed
  end
end
