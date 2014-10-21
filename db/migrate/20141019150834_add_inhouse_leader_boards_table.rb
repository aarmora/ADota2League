class AddInhouseLeaderBoardsTable < ActiveRecord::Migration
  def change

  	create_table :inhouseleaderboards do |t|
  		t.integer :player_id
  		t.integer :account_id
  		t.integer :season_id
  		t.integer :wins
  		t.integer :games_played
  		t.integer :kills
  		t.integer :deaths
  		t.integer :assists
  	end
  end
end
