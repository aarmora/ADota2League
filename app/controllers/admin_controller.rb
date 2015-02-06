class AdminController < ApplicationController
	before_filter :verify_admin

  def index
    if Permissions.user_is_site_admin?
      @permissions = Permission.includes(:player).all
      @players = Player.pluck(:id, :name)
    end
    @seasons = Season.all
  end

  def players
    @players = Player.order("name ASC").all
  end

  def teams
    @all_teams = Team.order(:name).pluck(:name, :id)
    @active_teams = Team.where(:active => false).order(:name).pluck(:name, :id)
    @inactive_teams = Team.where(:active => false).order(:name).pluck(:name, :id)
    @players = Player.order("name ASC").all
  end

  def manage_season
    # Get weeks or something?

  end
end
