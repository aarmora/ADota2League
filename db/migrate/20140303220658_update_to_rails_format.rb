class UpdateToRailsFormat < ActiveRecord::Migration

  def up
    # rename tables first because the syntax is a pain in the asshole
    rename_table "ad2lrails.aarmora.TeamTable", :teams
    rename_table "ad2lrails.aarmora.PlayerTable", :players
    rename_table "ad2lrails.aarmora.PlayerTeamTable", :players_teams
    rename_table "ad2lrails.aarmora.GameTable", :games
    rename_table "ad2lrails.aarmora.MatchTable", :matches
  end

  def down
    rename_table "ad2lrails.aarmora.teams", :TeamTable
    rename_table "ad2lrails.aarmora.players", :PlayerTable
    rename_table "ad2lrails.aarmora.players_teams", :PlayerTeamTable
    rename_table "ad2lrails.aarmora.games", :GameTable
    rename_table "ad2lrails.aarmora.matches", :MatchTable
  end
end
