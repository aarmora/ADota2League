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

	def new
		@seasons = Season.where(:active => true)

	end

	def get_players
		@season = Season.find(params[:season_id])

		@ts = @season.team_seasons.includes(:participant).where(:paid => true)
		@sl_matches = SoloLeagueMatch.where(:season_id => params[:season_id], :round => params[:round])
		@players = []
		alreadyScheduled = []
		@sl_matches.each do |sl|
			alreadyScheduled = alreadyScheduled + [sl.home_team_id_1, sl.home_team_id_2, sl.home_team_id_3,  sl.home_team_id_4,  sl.home_team_id_5,  sl.away_team_id1, sl.away_team_id2,  sl.away_team_id3,  sl.away_team_id4,  sl.away_team_id5]
		end
		@total_wins = {}
          @total_losses = {}
          @sl_matches.each do |match|
            if match.home_wins == true
              puts "home_wins"
              puts match.home_team_id_1
              #Add home win
              @total_wins[match.home_team_id_1] = @total_wins[match.home_team_id_1].to_i + 1
              @total_wins[match.home_team_id_2] = @total_wins[match.home_team_id_2].to_i + 1
              @total_wins[match.home_team_id_3] = @total_wins[match.home_team_id_3].to_i + 1
              @total_wins[match.home_team_id_4] = @total_wins[match.home_team_id_4].to_i + 1
              @total_wins[match.home_team_id_5] = @total_wins[match.home_team_id_5].to_i + 1

              #Add away loss
              @total_losses[match.away_team_id1] = @total_losses[match.away_team_id1].to_i + 1
              @total_losses[match.away_team_id2] = @total_losses[match.away_team_id2].to_i + 1
              @total_losses[match.away_team_id3] = @total_losses[match.away_team_id3].to_i + 1
              @total_losses[match.away_team_id4] = @total_losses[match.away_team_id4].to_i + 1
              @total_losses[match.away_team_id5] = @total_losses[match.away_team_id5].to_i + 1
            elsif match.home_wins == false
              puts "away_loses"
              #Add away win
              @total_wins[match.away_team_id1] = @total_wins[match.away_team_id1].to_i + 1
              @total_wins[match.away_team_id2] = @total_wins[match.away_team_id2].to_i + 1
              @total_wins[match.away_team_id3] = @total_wins[match.away_team_id3].to_i + 1
              @total_wins[match.away_team_id4] = @total_wins[match.away_team_id4].to_i + 1
              @total_wins[match.away_team_id5] = @total_wins[match.away_team_id5].to_i + 1

              #Add home loss
              @total_losses[match.home_team_id_1] = @total_losses[match.home_team_id_1].to_i + 1
              @total_losses[match.home_team_id_2] = @total_losses[match.home_team_id_2].to_i + 1
              @total_losses[match.home_team_id_3] = @total_losses[match.home_team_id_3].to_i + 1
              @total_losses[match.home_team_id_4] = @total_losses[match.home_team_id_4].to_i + 1
              @total_losses[match.home_team_id_5] = @total_losses[match.home_team_id_5].to_i + 1
            end
          end

		@ts.each do |ts|
			if !alreadyScheduled.include?(ts.participant.id)
				@players.push(ts.participant)
			end
		end


		render :json => @players#{:players => @players, :total_wins => @total_wins, :total_losses => @total_losses}

	end

	def create_match
		@players = JSON.parse(params[:players])
		@sl_match = SoloLeagueMatch.new
		@sl_match.round = params[:round]
		@sl_match.season_id = params[:season_id]
		@sl_match.lobby_password =  "ad2l" + rand(1000).to_s
		@sl_match.home_team_id_1 = @players[0]
		@sl_match.home_team_id_2 = @players[1]
		@sl_match.home_team_id_3 = @players[2]
		@sl_match.home_team_id_4 = @players[3]
		@sl_match.home_team_id_5 = @players[4]
		@sl_match.away_team_id1 = @players[5]
		@sl_match.away_team_id2 = @players[6]
		@sl_match.away_team_id3 = @players[7]
		@sl_match.away_team_id4 = @players[8]
		@sl_match.away_team_id5 = @players[9]
		@sl_match.save!
		
		render :nothing => true


	end

end
