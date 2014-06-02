class AddIndiciesToDb < ActiveRecord::Migration
  def change
    add_index :games, :match_id
    add_index :matchcomments, :match_id
    add_index :matches, :season_id
    add_index :matches, :home_team_id
    add_index :matches, :away_team_id
    add_index :player_votes, :recipient_id
    add_index :player_votes, :endorser_id
    add_index :players_teams, :team_id
    add_index :players_teams, :player_id
    add_index :team_seasons, :team_id
    add_index :team_seasons, [:season_id, :division]
  end
end
