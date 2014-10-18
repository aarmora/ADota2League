class InhousesController < ApplicationController

	def index
		@inhouse_games_ids = Inhousegame.where(:leagueid => 2047).uniq.pluck(:match_id)

		@games = Dota.history(:league_id => 2047)

		@all_games = Array.new

		@games.raw_history["matches"].each do |game|
			if !@inhouse_games_ids.include? game["match_id"]

				this_game = Dota.match(game["match_id"])
				if this_game.raw_match["duration"] > 600
					@all_games.push this_game
					this_game.raw_match["players"].each do |player|
						@inhouse_game = Inhousegame.new
						@inhouse_game.update_attributes(:barracks_status_dire => this_game.raw_match["barracks_status_dire"], :barracks_status_radiant => this_game.raw_match["barracks_status_radiant"], :cluster => this_game.raw_match["cluster"], :dire_captain => this_game.raw_match["dire_captain"])
						@inhouse_game.update_attributes(:duration => this_game.raw_match["duration"], :first_blood_time => this_game.raw_match["first_blood_time"], :game_mode => this_game.raw_match["human_players"],  :human_players => this_game.raw_match["human_players"], :leagueid => this_game.raw_match["leagueid"])
						@inhouse_game.update_attributes(:match_id => this_game.raw_match["match_id"], :match_seq_num => this_game.raw_match["match_seq_num"], :radiant_captain => this_game.raw_match["radiant_captain"], :radiant_win => this_game.raw_match["radiant_win"])
						@inhouse_game.update_attributes(:start_time => this_game.raw_match["start_time"], :tower_status_dire => this_game.raw_match["tower_status_dire"])
						@inhouse_game.update_attributes(:account_id => player["account_id"], :assists => player["assists"])
						@inhouse_game.update_attributes(:deaths => player["deaths"], :denies => player["denies"], :gold_per_min => player["gold_per_min"], :gold_spent => player["gold_spent"], :hero_damage => player["hero_damage"], :hero_healing => player["hero_healing"])
						@inhouse_game.update_attributes(:hero_id => player["hero_id"], :kills => player["kills"], :last_hits => player["last_hits"], :leaver_status => player["leaver_status"], :level => player["level"], :tower_damage => player["tower_damage"], :xp_per_min => player["xp_per_min"])
						@inhouse_game.save!
					end
				end
			end
		end

		render :json => @all_games
	end

	def show
		@inhouse_games = Inhousegame.where(:leagueid => params[:id]).group("account_id")


		@player = Player.where(:steam32id => 120576947)
		#@player = Player.find_by_steam32id(117746246)
		@team = Team.find(2499)

		@this_game = Dota.match(963087747)

		render :json => @this_game
		
	end

end