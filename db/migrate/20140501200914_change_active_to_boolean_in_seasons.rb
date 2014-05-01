class ChangeActiveToBooleanInSeasons < ActiveRecord::Migration
  def up
    change_column :seasons, :active, :boolean, :null => false, :default => false
  end

  def down
    change_column :seasons, :active, :integer, :null => true
  end
end
