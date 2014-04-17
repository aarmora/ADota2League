class Player < ActiveRecord::Base
  has_and_belongs_to_many :teams
  has_many :authored_posts, :class_name => "Post", :foreign_key => "author_id"
  has_many :captained_teams, :class_name => "Team", :foreign_key => "captain_id"
  has_many :casted_matches, :class_name => "Match", :foreign_key => "caster_id"
  has_many :matches_commented, :class_name => "Matchcomment", :foreign_key => "player_id"

  
  attr_accessible :name, :email, :freeagentflag, :role, :as => [:default, :caster, :admin]
  attr_accessible :twitch, :region, :as => [:admin, :caster]
  attr_accessible :caster, :admin, :as => :admin
  
  def is_admin?
  	# TODO: Move into an ENV config?
  	#                  Havoc                 Kered              ShadowKiller         Rasputin
  	steam_ids = ["76561197969226815", "76561198064440065", "76561198096413824", "76561198040889152"]
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
