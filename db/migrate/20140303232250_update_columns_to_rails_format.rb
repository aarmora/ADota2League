class UpdateColumnsToRailsFormat < ActiveRecord::Migration
  def with_table_name_prefix(prefix)
    old_prefix = ActiveRecord::Base.table_name_prefix
    ActiveRecord::Base.table_name_prefix = prefix
    yield
  ensure
    ActiveRecord::Base.table_name_prefix = old_prefix
  end

  def change
    with_table_name_prefix("AD2Ltest.aarmora.") do
      rename_column :teams, :teamkey, :id
      rename_column :teams, :cptkey, :captain_id
      rename_column :teams, :teamid, :dotabuff_id
      rename_column :players, :playerkey, :id
      rename_column :players, :teamkey, :team_id
      rename_column :players, :playername, :name
      rename_column :players, :playeremail, :email
      rename_column :players_teams, :playerteamkey, :id
      rename_column :players_teams, :playerkey, :player_id
      rename_column :players_teams, :teamkey, :team_id
      rename_column :games, :gamekey, :id
      rename_column :games, :matchkey, :match_id
      rename_column :games, :matchid, :steam_match_id
      # NOTE: Do we need these? They should be join-able, I can't tell how they are used though. Steam scraper?
      rename_column :games, :direname, :dire_team_name
      rename_column :games, :direteamid, :dire_team_id
      rename_column :games, :radiantname, :radiant_team_name
      rename_column :games, :radiantteamid, :radiant_team_id
      #####
      rename_column :matches, :matchkey, :id
      rename_column :matches, :hometeamkey, :home_team_id
      rename_column :matches, :awayteamkey, :away_team_id
      rename_column :matches, :matchdate, :date
      rename_column :matches, :homescore, :home_score
      rename_column :matches, :awayscore, :away_score
      rename_column :matches, :steammatchid, :steam_match_id
      rename_column :matches, :disputeflag, :is_disputed
      rename_column :matches, :liveflag, :is_live
    end
  end
end
