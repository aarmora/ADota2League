class Player < ActiveRecord::Base
  has_and_belongs_to_many :teams
  has_many :authored_posts, :class_name => "Post", :foreign_key => "author_id"
  has_many :captained_teams, :class_name => "Team", :foreign_key => "captain_id"
  has_many :casted_matches, :class_name => "Match", :foreign_key => "caster_id"
  has_many :matches_commented, :class_name => "Matchcomment", :foreign_key => "player_id"

  # Endorsers are people who "voted" for this person. Endorsed players are people this user voted for
  has_many :endorsements, :class_name => "PlayerVote", :foreign_key => "recipient_id", :dependent => :delete_all
  has_many :endorsers, :through => :endorsements
  has_many :outgoing_endorsements, :class_name => "PlayerVote", :foreign_key => "endorser_id", :dependent => :delete_all


  attr_accessible :name, :bio, :email, :time_zone, :freeagentflag, :role, :mmr, :hours_played, :as => [:default, :caster, :admin]
  attr_accessible :twitch, :region, :as => [:admin, :caster]
  attr_accessible :caster, :admin, :as => :admin

  def is_admin?
  	# TODO: Move into an ENV config?
  	#                  Havoc                 Kered              ShadowKiller         Rasputin             Affinity
  	steam_ids = ["76561197969226815", "76561198064440065", "76561198096413824", "76561198040889152", "76561198062137050"]
  	steam_ids.include? self.steamid
  end

  def permission_role
  	if self.is_admin?
  		:admin
  	elsif self.caster
  		:caster
  	else
  		:default
  	end
  end
end
