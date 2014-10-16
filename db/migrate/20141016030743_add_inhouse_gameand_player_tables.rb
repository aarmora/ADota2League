class AddInhouseGameandPlayerTables < ActiveRecord::Migration
  def change

  	create_table :inhousegames do |t|
  		t.integer :barracks_status_dire
  		t.integer :barracks_status_radiant
  		t.integer :cluster
  		t.integer :dire_captain
  		t.integer :duration
  		t.integer :first_blood_time
  		t.integer :game_mode
  		t.integer :human_players
  		t.integer :leagueid
  		t.integer :lobby_type
  		t.integer :match_id
  		t.integer :match_seq_num
  		t.integer :negative_votes
  		t.integer :positive_votes
  		t.integer :radiant_captain
  		t.integer :radiant_win
  		t.integer :start_time
  		t.integer :tower_status_dire
  		t.integer :tower_status_dire
  		t.integer :account_id
  		t.integer :assists
  		t.integer :deaths
  		t.integer :denies
  		t.integer :gold
  		t.integer :gold_per_min
  		t.integer :gold_spent
  		t.integer :hero_damage
  		t.integer :hero_healing
  		t.integer :hero_id
  		t.integer :kills
  		t.integer :last_hits
  		t.integer :leaver_status
  		t.integer :level
  		t.integer :player_slot
  		t.integer :tower_damage
  		t.integer :xp_per_min
  		t.timestamps
  	end  

  end
end
