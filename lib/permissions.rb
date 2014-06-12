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
          TeamSeason.where(:season_id => object.season_id, :division => p.division, :team_id => [object.home_team_id, object.away_team_id]).count > 0
        )
      end
    elsif object.is_a? Team
      user.captained_teams.include? object
    elsif object.is_a? Player
      object.id == user.id
    else
      false # anything else only site admins can do
    end
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

  def role_for_object(object)
    if Permissions.can_edit? object
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

  def self.managed_teams

  end

  def self.current_user=(user) #set current_user
    @current_user = user
  end

  def self.current_user #get current_user
    @current_user
  end
end