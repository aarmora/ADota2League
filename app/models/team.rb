class Team < ActiveRecord::Base
  has_and_belongs_to_many :players

  # TODO: I think I can make this a straight association by writing custom select / join code...
  has_many :home_matches, :class_name => 'Match', :foreign_key => "home_team_id"
  has_many :away_matches, :class_name => 'Match', :foreign_key => "away_team_id"
  belongs_to :captain, :class_name => "Player"
  has_many :team_seasons, :dependent => :delete_all
  has_many :seasons, :through => :team_seasons

  attr_accessible :teamname, :region, :originalmmr, :as => [:default, :admin]
  attr_accessible :dotabuff_id, :captain_id, :mmr, :active, :as => :admin

  # Note: this will probably be read only
  def matches
     home_matches + away_matches
  end

  def default_mmr
    2567
  end

  def self.available_for_season_and_week(season_id, week)
    @result_map ||= {}
    cache_key = season_id.to_s + "-" + week.to_s
    playing_ids = (Match.where(:season_id => season_id, :week => week).pluck(:away_team_id) + Match.where(:season_id => season_id, :week => week).pluck(:home_team_id)).compact
    Team.joins(:team_seasons).where(Team.arel_table[:id].not_in(playing_ids)).where(:team_seasons => {:season_id => season_id}).pluck(:id, :teamname)
  end

  def seasons_available_for_registration
    current_season_groups = self.seasons.where("exclusive_group IS NOT NULL").pluck(:exclusive_group)
    result = Season.where(:registration_open => true)
    result = result.where("id NOT IN (:seasons)", {:seasons => self.seasons.pluck(:id)}) unless self.seasons.empty?
    result = result.where("exclusive_group IS NULL OR exclusive_group NOT IN (:used_groups)", {:used_groups => current_season_groups}) unless current_season_groups.empty?
    result
  end

  def can_register_for_new_season?
    seasons_available_for_registration.exists?
  end
end
