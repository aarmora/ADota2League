class SoloLeagueMatch < ActiveRecord::Base
	belongs_to :home_player_1, :class_name => "Player", :foreign_key => "home_team_id_1"
	belongs_to :home_player_2, :class_name => "Player", :foreign_key => "home_team_id_2"
	belongs_to :home_player_3, :class_name => "Player", :foreign_key => "home_team_id_3"
	belongs_to :home_player_4, :class_name => "Player", :foreign_key => "home_team_id_4"
	belongs_to :home_player_5, :class_name => "Player", :foreign_key => "home_team_id_5"

	belongs_to :away_player_1, :class_name => "Player", :foreign_key => "away_team_id1"
	belongs_to :away_player_2, :class_name => "Player", :foreign_key => "away_team_id2"
	belongs_to :away_player_3, :class_name => "Player", :foreign_key => "away_team_id3"
	belongs_to :away_player_4, :class_name => "Player", :foreign_key => "away_team_id4"
	belongs_to :away_player_5, :class_name => "Player", :foreign_key => "away_team_id5"

  def home_participant_class_id
    "#{home_participant_type}/#{home_participant_id}"
  end
  def away_participant_class_id
    "#{away_participant_type}/#{away_participant_id}"
  end
  
end