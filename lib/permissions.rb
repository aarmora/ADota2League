module Permissions

  # Static methods assume that we'll always be looking at @current user
  def self.can_edit?(object, user = nil)
    user ||= @current_user
    return false unless user && object
    return true if self.user_is_site_admin?(user)

    if object.is_a? Season
      self.permissions_for_user(user).detect {|p| p.season_id == object.id && p.permission_mode == "season"}
    elsif object.is_a? TeamSeason
      self.permissions_for_user(user).detect do |p|
        (p.season_id == object.season_id && p.permission_mode == "season") ||
        (p.season_id == object.season_id && p.division == object.division && p.permission_mode == "division")
      end
    elsif object.is_a? Match
      self.permissions_for_user(user).detect do |p|
        (p.season_id == object.season_id && p.permission_mode == "season") ||
        (p.season_id == object.season_id && p.permission_mode == "division" &&
          # Check the mapping if it exists, otherwise lookup on the fly
          (@ts_season == object.season_id ?
            (@ts_map[object.home_team_id] == p.division || @ts_map[object.home_team_id] == p.division)
            :
            TeamSeason.where(:season_id => object.season_id, :division => p.division, :team_id => [object.home_team_id, object.away_team_id]).count > 0
          )
        ) || # captains of either team are AOK
        (!@match_captain_permissions_off && (user.captained_teams.include?(home_team) || user.captained_teams.include?(away_team)))
      end
    elsif object.is_a? Team
      user.captained_teams.include? object
    elsif object.is_a? Player
      object.id == user.id
    else
      false # anything else only site admins can do
    end
  end

  # This is probably not the best way to do this, but we allow pages to "cue" us that we're
  # going to be looking up the teams in a given season, thereby creating a map to be used above
  def self.load_team_divisions_for_season(season_id)
    data = TeamSeason.where(:season_id => season_id).pluck_all(:team_id, :division)
    @ts_map = data.inject({}) {|r, val| r[val[0]] = val[1]; r}
    @ts_season = season_id
  end

  # Niche case used only for seasons right now
  def self.can_view?(object, user = nil)
    user ||= @current_user
    return false unless user && object
    return true if self.user_is_site_admin?(user)

    if object.is_a? Season
      self.permissions_for_user(user).detect {|p| p.season_id == object.id && (p.permission_mode == "season" || p.permission_mode == "division")}
    else
      false # anything else only site admins can do
    end
  end

  # Mixed in to permissions
  def role_for_object(object)
    # Order is important here as captains may change some but NOT all things via mass update
    if object.is_a?(Match) && (self.captained_teams.include?(object.home_team) || self.captained_teams.include?(object.away_team))
      :captain
    elsif Permissions.can_edit? object
      :admin
    else
      :default
    end
  end

  def self.user_is_site_admin?(user = nil)
    user ||= @current_user
    self.permissions_for_user(user).detect {|p| p.permission_mode == "site"}
  end

  def self.permissions_for_user(user = nil)
    user ||= @current_user
    user ? user.permissions : []
  end

   def self.user_has_permissions?(user = nil)
    user ||= @current_user
    !self.permissions_for_user(user).empty?
  end

  # This is terrible, but allows us to disallow captains from editing on the season page
  def self.match_captain_permissions_off
    @match_captain_permissions_off = true
  end

  def self.current_user=(user) #set current_user
    @current_user = user
  end

  def self.current_user #get current_user
    @current_user
  end
end