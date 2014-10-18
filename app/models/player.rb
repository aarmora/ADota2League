class Player < ActiveRecord::Base
  include Permissions

  has_and_belongs_to_many :teams
  has_many :authored_posts, :class_name => "Post", :foreign_key => "author_id"
  has_many :captained_teams, :class_name => "Team", :foreign_key => "captain_id"
  has_many :casted_matches, :class_name => "Match", :foreign_key => "caster_id"
  has_many :matches_commented, :class_name => "Matchcomment", :foreign_key => "player_id"
  has_many :permissions, :class_name => "Permission", :foreign_key => "player_id"
  has_many :inhouse_games, :class_name => "Inhousegame", :foreign_key => "account_id", :primary_key => "steam32id"

  # Endorsers are people who "voted" for this person. Endorsed players are people this user voted for
  has_many :endorsements, :class_name => "PlayerVote", :foreign_key => "recipient_id", :dependent => :delete_all
  has_many :endorsers, :through => :endorsements
  has_many :outgoing_endorsements, :class_name => "PlayerVote", :foreign_key => "endorser_id", :dependent => :delete_all

  has_many :player_comments, :class_name => "PlayerComment", :foreign_key => "recipient_id", :dependent => :delete_all
  has_many :commenters, :through => :player_comments
  has_many :outgoing_comments, :class_name => "PlayerComment", :foreign_key => "commenter_id", :dependent => :delete_all

  attr_accessible :name, :bio, :email, :time_zone, :freeagentflag, :role, :mmr, :hours_played, :as => [:default, :caster, :admin]
  attr_accessible :twitch, :region, :as => [:admin, :caster]
  attr_accessible :caster, :admin, :as => :admin

end

