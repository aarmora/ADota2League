class Player < ActiveRecord::Base
  has_and_belongs_to_many :teams
  has_many :captained_teams, :class_name => "Team", :foreign_key => "captain_id"
  # attr_accessible :title, :body
end
