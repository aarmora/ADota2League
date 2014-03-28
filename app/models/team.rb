class Team < ActiveRecord::Base
  has_and_belongs_to_many :players

  # TODO: I think I can make this a straight association by writing custom select / join code...
  has_many :home_matches, :class_name => 'Match', :foreign_key => "home_team_id"
  has_many :away_matches, :class_name => 'Match', :foreign_key => "away_team_id"
  has_one :captain, :class_name => "Player"
  has_many :team_seasons, :dependent => :delete_all

  attr_accessible :teamname, :region, :originalmmr, :as => [:default, :admin]
  attr_accessible :dotabuff_id, :captain_id, :mmr, :as => :admin

  # Note: this will probably be read only
  def matches
     home_matches + away_matches
  end


  def self.available_for_season_and_week(season_id, week)
    @result_map ||= {}
    cache_key = season_id.to_s + "-" + week.to_s
    @result_map[cache_key] ||= begin
      playing_ids = (Match.where(:season_id => season_id, :week => week).pluck(:away_team_id) + Match.where(:season_id => season_id, :week => week).pluck(:home_team_id)).compact
      Team.joins(:team_seasons).where(Team.arel_table[:id].not_in(playing_ids)).where(:team_seasons => {:season_id => season_id})
    end
  end
end
