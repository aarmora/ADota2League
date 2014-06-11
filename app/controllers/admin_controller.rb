class AdminController < ApplicationController
	before_filter :verify_admin

  def index
    if Permissions.user_is_site_admin?
      @permissions = Permission.all
      @players = Player.pluck_all(:id, :name)
    end
    @seasons = Season.all
  end

  def players
    @players = Player.order("name ASC").all
  end

  def teams
    @all_teams = Team.order(:teamname).pluck_all(:teamname, :id)
    @active_teams = Team.where(:active => false).order(:teamname).pluck_all(:teamname, :id)
    @inactive_teams = Team.where(:active => false).order(:teamname).pluck_all(:teamname, :id)

  end

  def manage_season
    # Get weeks or something?

  end
end
