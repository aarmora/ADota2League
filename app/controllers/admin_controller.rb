class AdminController < ApplicationController
	before_filter :verify_admin

  def index
    if Permissions.user_is_site_admin?
      @teams = Team.includes(:captain).all
      @players = Player.all
    end
    @seasons = Season.all

    @permissions = Permission.all
  end

  def players
    @players = Player.includes(:teams).all
  end

  def manage_season
    # Get weeks or something?

  end
end
