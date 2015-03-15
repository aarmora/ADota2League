class Player < ActiveRecord::Base
  include Permissions

  has_and_belongs_to_many :teams
  has_many :authored_posts, :class_name => "Post", :foreign_key => "author_id"
  has_many :captained_teams, :class_name => "Team", :foreign_key => "captain_id"
  has_many :casted_matches, :class_name => "Match", :foreign_key => "caster_id"
  has_many :matches_commented, :class_name => "Matchcomment", :foreign_key => "player_id"
  has_many :permissions, :class_name => "Permission", :foreign_key => "player_id"
  has_many :inhouse_games, :class_name => "Inhousegame", :foreign_key => "account_id", :primary_key => "steam32id"

  # Players participant in tournaments
  has_many :team_seasons, :dependent => :delete_all, :as => :participant
  has_many :seasons, :through => :team_seasons
  has_many :home_matches, :class_name => 'Match', :as => :home_participant
  has_many :away_matches, :class_name => 'Match', :as => :away_participant

  # Endorsers are people who "voted" for this person. Endorsed players are people this user voted for
  has_many :endorsements, :class_name => "PlayerVote", :foreign_key => "recipient_id", :dependent => :delete_all
  has_many :endorsers, :through => :endorsements
  has_many :outgoing_endorsements, :class_name => "PlayerVote", :foreign_key => "endorser_id", :dependent => :delete_all

  has_many :player_comments, :class_name => "PlayerComment", :foreign_key => "recipient_id", :dependent => :delete_all
  has_many :commenters, :through => :player_comments
  has_many :outgoing_comments, :class_name => "PlayerComment", :foreign_key => "commenter_id", :dependent => :delete_all

  attr_accessible :name, :bio, :email, :time_zone, :freeagentflag, :role, :mmr, :hours_played, :steamid, :receive_emails, :as => [:default, :caster, :admin]
  attr_accessible :real_name, :country, :avatar, :twitch, :region, :as => [:admin, :caster]
  attr_accessible :caster, :admin, :as => :admin

  def class_id
    "Player/#{id}"
  end

  def seasons_available_for_registration
    current_season_groups = self.seasons.where("exclusive_group IS NOT NULL").pluck(:exclusive_group)
    result = Season.where(:registration_open => true, :team_tourney => false)
    result = result.where("id NOT IN (:seasons)", {:seasons => self.seasons.pluck(:id)}) unless self.seasons.empty?
    result = result.where("exclusive_group IS NULL OR exclusive_group NOT IN (:used_groups)", {:used_groups => current_season_groups}) unless current_season_groups.empty?
    result
  end

end
