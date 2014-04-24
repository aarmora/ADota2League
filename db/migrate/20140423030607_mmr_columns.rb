class MmrColumns < ActiveRecord::Migration
  def change
    add_column :players, :mmr, :integer
    add_column :players, :hours_played, :integer
  end
end
