class AddColumnsToGames < ActiveRecord::Migration
  def up
    change_column :games, :radiantwin, :boolean
    rename_column :games, :radiantwin, :radiant_win
    add_column :games, :created_at, :timestamp
    add_column :games, :updated_at, :timestamp
    rename_column :games, :dire_team_id, :dire_dota_team_id
    rename_column :games, :radiant_team_id, :radiant_dota_team_id
    add_column :games, :dire_team_id, :integer
    add_column :games, :radiant_team_id, :integer
  end

  def down
    remove_column :games, :radiant_team_id
    remove_column :games, :dire_team_id
    remove_column :games, :created_at
    remove_column :games, :updated_at
    rename_column :games, :dire_dota_team_id, :dire_team_id
    rename_column :games, :radiant_dota_team_id, :radiant_team_id
    rename_column :games, :radiant_win, :radiantwin
    change_column :games, :radiantwin, :string
  end
end
