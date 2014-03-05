class Match < ActiveRecord::Base
  has_many :games, :dependent => :destroy
  belongs_to :home_team, :class_name => "Team"
  belongs_to :away_team, :class_name => "Team"
  # attr_accessible :title, :body
end
