class SoloLeaguesController < ApplicationController	
	before_filter :verify_admin

	def index
		#redirect_to show
	end

	def show
		if params[:id]
			@season = Season.find(params[:id])
		else
			@season = Season.where(:team_tourney => false, :active => true).first
		end

		@solo_league_matches = SoloLeagueMatch.where(:season_id => @season.id).includes(:home_player_1, :home_player_2, :home_player_3, :home_player_4, :home_player_5, :away_player_1, :away_player_2, :away_player_3, :away_player_4, :away_player_5)

	end

	def update_score
		@match = SoloLeagueMatch.find(params[:match_id])

		@match.home_wins = params[:home_wins]
		@match.save!
		puts @match

		render :nothing => true
	end

end
