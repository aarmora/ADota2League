class AddNextMatchIdToMatchesAndMore < ActiveRecord::Migration
  def change
    add_column :matches, :winner_match_id, :integer, :null => true
    add_column :matches, :loser_match_id, :integer, :null => true

    # Allow nil participants in matches (pre-scheduling with TBD teams)
    reversible do |dir|
      dir.up do
        change_column :matches, :home_participant_type, :string, null: true, default: "Team"
        change_column :matches, :away_participant_type, :string, null: true, default: "Team"
        change_column :seasons, :season_type, :integer, null: false, default: 0

        # Decrement all season types by one
        execute <<-SQL
          UPDATE seasons
            SET season_type = season_type - 1
            WHERE season_type IS NOT NULL
        SQL
        execute <<-SQL
          UPDATE seasons
            SET season_type = 1
            WHERE season_type IS NULL
        SQL
      end
      dir.down do
        # These can't be undone because the nulls won't auto-cast to strings, nor do we want them to
        # change_column :matches, :home_participant_type, :string, null: false, default: "Team"
        # change_column :matches, :away_participant_type, :string, null: false, default: "Team"
        change_column :seasons, :season_type, :integer, null: true, default: 1

        # increment all season types by 1
        execute <<-SQL
          UPDATE seasons
            SET season_type = season_type + 1
            WHERE season_type IS NOT NULL
        SQL
      end
    end
  end
end
