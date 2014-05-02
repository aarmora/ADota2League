class TeamSeason < ActiveRecord::Base
	attr_accessible :season, :division, :team
	belongs_to :season
	belongs_to :team

  validates :team_id, :uniqueness => {:scope => :season_id, :message => "may only register for a season once"}

  attr_accessible :paid, :division, :as => :admin
end
