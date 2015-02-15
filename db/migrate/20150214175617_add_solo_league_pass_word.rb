class AddSoloLeaguePassWord < ActiveRecord::Migration
  def change
    add_column :solo_league_matches, :lobby_password, :string
  end
end
