class AddPolymorhismToTeamSeason < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_index :matches, :home_team_id
        remove_index :matches, :away_team_id
        remove_index :team_seasons, :team_id
      end
      dir.down do
        add_index :matches, :home_team_id
        add_index :matches, :away_team_id
        add_index :team_seasons, :team_id
      end
    end

    rename_column :team_seasons, :team_id, :participant_id
    add_column :team_seasons, :participant_type, :string, null: false, default: "Team"

    rename_column :matches, :home_team_id, :home_participant_id
    add_column :matches, :home_participant_type, :string, null: false, default: "Team"

    rename_column :matches, :away_team_id, :away_participant_id
    add_column :matches, :away_participant_type, :string, null: false, default: "Team"

    rename_column :teams, :teamname, :name

    reversible do |dir|
      dir.up do
        add_index :matches, [:home_participant_id, :home_participant_type]
        add_index :matches, [:away_participant_id, :away_participant_type]
        add_index :team_seasons, [:participant_id, :participant_type]
      end
      dir.down do
        # Remove all entries where the type equals Player because those will pollute the old DB
        execute <<-SQL
          DELETE FROM matches
            WHERE home_participant_type = "Player" OR away_participant_type = "Player"
        SQL
        execute <<-SQL
          DELETE FROM team_seasons
            WHERE participant_type = "Player"
        SQL
        remove_index :matches, [:home_participant_id, :home_participant_type]
        remove_index :matches, [:away_participant_id, :away_participant_type]
        remove_index :team_seasons, [:participant_id, :participant_type]
      end
    end
  end
end
