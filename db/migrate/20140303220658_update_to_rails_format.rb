class UpdateToRailsFormat < ActiveRecord::Migration

  def up
    # rename tables first because the syntax is a pain in the asshole
    rename_table "ad2ltest.aarmora.TeamTable", :teams
    rename_table "ad2ltest.aarmora.PlayerTable", :players
    rename_table "ad2ltest.aarmora.PlayerTeamTable", :players_teams
    rename_table "ad2ltest.aarmora.GameTable", :games
    rename_table "ad2ltest.aarmora.MatchTable", :matches
  end

  def down
    rename_table "ad2ltest.aarmora.teams", :TeamTable
    rename_table "ad2ltest.aarmora.players", :PlayerTable
    rename_table "ad2ltest.aarmora.players_teams", :PlayerTeamTable
    rename_table "ad2ltest.aarmora.games", :GameTable
    rename_table "ad2ltest.aarmora.matches", :MatchTable
  end
end
