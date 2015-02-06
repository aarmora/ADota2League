class AddTourneyType < ActiveRecord::Migration
  def change  	
    add_column :seasons, :season_type, :int, default: 1
    add_column :seasons, :team_tourney, :boolean, default: true


	create_table "season_types", :force => true do |t|
	    t.string "Season type"
	end
  end
end
