# NOTE: This needs to be refactored to ParticipantSeason or something less specific
class TeamSeason < ActiveRecord::Base
	attr_accessible :season, :division, :team
	belongs_to :season
  belongs_to :participant, polymorphic: true

  validates :participant_id, :uniqueness => {:scope => :season_id, :message => "may only register for a season once"}

  attr_accessible :paid, :division, :as => :admin
  attr_accessible :checked_in, :as => [:default, :caster, :admin]

  # class_id is used to identify the type and id so as not to confuse players and teams with the same actual id
  def class_id
    "#{participant_type}/#{participant_id}"
  end
end
