class Season < ActiveRecord::Base
	has_many :team_seasons, :dependent => :delete_all
	has_many :teams, :through => :team_seasons
	has_many :matches
end
