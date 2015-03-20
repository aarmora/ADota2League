# NOTE: This needs to be refactored to ParticipantSeason or something less specific
class TeamSeason < ActiveRecord::Base
	belongs_to :season
  belongs_to :participant, polymorphic: true

  validates :participant_id, :uniqueness => {:scope => :season_id, :message => "may only register for a season once"}

  # class_id is used to identify the type and id so as not to confuse players and teams with the same actual id
  def class_id
    "#{participant_type}/#{participant_id}"
  end
end
