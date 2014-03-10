class TeamSeason < ActiveRecord::Base
	attr_accessible :season, :division, :team
	belongs_to :season
	belongs_to :team
end
