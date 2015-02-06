class AddSoloLeagueMatchTable < ActiveRecord::Migration
  def change
	create_table "solo_league_matches", :force => true do |t|
	    t.integer "home_team_id_1"
	    t.integer "home_team_id_2"
	    t.integer "home_team_id_3"
	    t.integer "home_team_id_4"
	    t.integer "home_team_id_5"
	    t.integer "away_team_id1"
	    t.integer "away_team_id2"
	    t.integer "away_team_id3"
	    t.integer "away_team_id4"
	    t.integer "away_team_id5"
	    t.boolean "home_wins"
	    t.integer "round"
	   	t.integer "season_id"
  	end


    add_column :seasons, :solo_league, :boolean, :default => false
  end
end
