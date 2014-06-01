class Permission < ActiveRecord::Base
  belongs_to :player, :class_name => "Player"
  belongs_to :season, :class_name => "Season"
  attr_accessible :player_id, :permission_mode, :organization_id, :season_id, :division

  # Static methods assume that we'll always be looking at @current user
  def self.can_admin?(object, user = nil)
    user ||= @current_user
    return false unless user && object
    return true if self.user_is_site_admin?(user)
    return false if self.permissions_for_user(user).empty?

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
    else
      false # anything else only site admins can do
    end
  end

  def self.user_is_site_admin?(user = nil)
    user ||= @current_user
    self.permissions_for_user(user).detect {|p| p.permission_mode == "site"}
  end

  def self.permissions_for_user(user = nil)
    user ||= @current_user
    @permissions ||= user.permissions
  end

  def self.managed_teams

  end
end