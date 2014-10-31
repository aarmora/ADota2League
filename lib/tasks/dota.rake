namespace :dota do
  desc "Update our local games table from the DotA API"
  task :pull_games => :environment do
  	# NOTE: This might need to be run while no games are going on. Unclear if it returns in-progress matches
  	# NOTE: Dota API "matches" are really just single games AFAIK. That convolutes the notation a bit.

    dups = Team.connection.select_all("SELECT dotabuff_id, COUNT(*) as count FROM teams WHERE dotabuff_id IS NOT NULL GROUP BY dotabuff_id HAVING COUNT(*) > 1")
    unless dups.empty?
      puts "WARNING: Some teams have the same dotabuff id. This can cause issues and should be fixed by merging or removing the teams (carefully)"
      puts "Duplicate ids:"
      dups.each do |item|
        puts "#{item["dotabuff_id"]} - #{item["count"]}"
      end
      puts "-------"
      puts ""
    end

  	puts "What season id?"
    season_id = STDIN.gets.chomp.to_i
    @season = Season.find(season_id)
  	league_id = @season.league_id
    raise "Season does not have dota league id set" unless league_id

    # TODO: Get dotabuff ids from ONLY teams registered for this season

    @seen_games = Game.pluck(:steam_match_id)

  	# Get the last game in our table from this league
  	# NOTE: We do not have this mapping right now, so we're looking at all games :(

  	last_start_id = nil

    # Matches API starts with highest match id, so we go while matches are greater than our last seen
  	# last_seen_id = Game.where(:match_id => @season.matches.pluck(:id)).maximum(:steam_match_id) || 0
    # puts "Working backwards from now to game #{last_seen_id}"

    # Just run everything in the season until we are actually raping the API
    last_seen_id = 0

  	begin
     last_start_id = last_start_id - 1 if last_start_id
  	 puts "Pulling a batch of games starting at #{last_start_id}"
  	 history = Dota.history(:league_id => league_id, :start_at_match_id => last_start_id)
  	 matches = history.matches
  	 break if matches.empty?
  	 matches.each do |match|
  	 	last_start_id = match.id
  	 	break if last_start_id <= last_seen_id

  	 	# Double check it doesn't exist, just in case...I don't think we'd want that
  	 	if @seen_games.include? match.id.to_i
        puts "Skipping seen game #{match.id}"
        next
      end

  	 	# We haven't seen this match yet, let's fetch the details and insert it
  	 	dota_match = Dota.match(match.id)

      if dota_match.raw_match["dire_team_id"].blank? || dota_match.raw_match["radiant_team_id"].blank?
        puts "Skipping game without two teams #{match.id}"
        next
      end

  	 	# Don't save it yet, let's see if we can find the match
  	 	game_entry = Game.new(
  	 		:steam_match_id => dota_match.id,
  	 		:dire_dota_team_id => dota_match.raw_match["dire_team_id"],
  	 		:dire_team_name => dota_match.raw_match["dire_name"],
  	 		:radiant_dota_team_id => dota_match.raw_match["radiant_team_id"],
  	 		:radiant_team_name => dota_match.raw_match["radiant_name"],
  	 		:radiant_win => dota_match.raw_match["radiant_win"]
  	 	)
      puts ""
  	 	puts "Processing #{match.id}: #{game_entry[:radiant_team_name]} (#{game_entry[:radiant_dota_team_id]}) vs. #{game_entry[:dire_team_name]} (#{game_entry[:dire_dota_team_id]})"

  	 	# Try to match the team ids from steam to those in our database
  	 	dire_team = Team.find_by_dotabuff_id(game_entry.dire_dota_team_id)
  	 	radiant_team = Team.find_by_dotabuff_id(game_entry.radiant_dota_team_id)
  	 	if dire_team && radiant_team
        game_entry.dire_team_id = dire_team.id
        game_entry.radiant_team_id = radiant_team.id
  	 		m = Match.where(:season_id => @season.id, :away_team_id => [dire_team.id, radiant_team.id], :home_team_id => [dire_team.id, radiant_team.id]).first
  	 		# NOTE: This is time boxed, so the game should take place within a week of the scheduled match for auto-matching
  	 		if m && (dota_match.start.to_date - m.date.to_date).abs <= 8
  	 			game_entry.match_id = m.id
  	 			puts "Found matching match! #{m.id}"
  	 			# TODO: adjust MMR here based on results?
          game_entry.save!
          m.update_score_from_games!
          @seen_games << match.id.to_i
  	 		else
          puts "Match not found or out of 8-day time box: #{m.inspect}"
          puts "Radiant DB team: #{radiant_team.id}"
          puts "Dire DB Team: #{dire_team.id}"
        end
  	 	else
        puts "Unable to find teams in DB for match."
        puts "no dire team found: #{dota_match.raw_match["dire_name"]}(#{dota_match.raw_match["dire_team_id"]})" if !dire_team
        puts "no radiant team found: #{dota_match.raw_match["radiant_name"]}(#{dota_match.raw_match["radiant_team_id"]})" if !radiant_team
      end
  	 end
  	end while last_start_id > last_seen_id
  end

  desc "Adjust MMR for a given league and week based on results"
  task :mmr => :environment do

    K = 150 # Adjust to allow more fluctuation


    ################ Run!!! ####################
    puts "What season id?"
    season_id = STDIN.gets.chomp.to_i

    @season = Season.find(season_id)

    if @season.challonge_id.blank?
      puts "What week are we adjusting the MMR based on matches for? "
      week_number = STDIN.gets.chomp.to_i
      if week_number < 1 || week_number > 15
        raise "This appears to be an invalid week"
      end
    end

    # make sure there's actually results
    @matches = if week_number
      @season.matches.includes(:home_team, :away_team).where(:week => week_number, :mmr_processed => false).where("forfeit IS NULL OR forfeit = 0")
    else
      @season.matches.includes(:home_team, :away_team).where(:mmr_processed => false).where("forfeit IS NULL OR forfeit = 0")
    end
    raise "No results for this week/season" unless @matches.exists?

    elo_holder = []

    @team_elos = {}

    @matches.each do |match|
      home_team = match.home_team
      away_team = match.away_team
      home_wins = match.home_score
      away_wins = match.away_score
      if away_wins == 0 && home_wins == 0
        puts "No wins detected for match: #{match.id} checking games"

        # See if there are games we logged that might change the scores
        match.update_score_from_games!
        home_wins = match.home_score
        away_wins = match.away_score

        # still no wins? then we skip it
        if away_wins == 0 && home_wins == 0
          puts "skipping match with no results: #{match.id}"
          next
        end
      end

      if !home_team || !away_team
        puts "skipping match with missing team"
        next
      end

      home_mmr = @team_elos[home_team.id] || home_team.mmr
      away_mmr = @team_elos[away_team.id] || away_team.mmr
      #                                                                      1200 is to spread out far apart MMRs, you do still have a chance!
      num_games_played = home_wins + away_wins
      exp_home_win = 1.0 / ( 10.0 ** ((away_mmr - home_mmr) / 1200.0) + 1) * num_games_played # Number of games = 2.0 TODO: maybe should be actual num games
      exp_away_win = num_games_played - exp_home_win

      home_games_played = home_team.matches.count
      away_games_played = away_team.matches.count

      # Make K dynamic based on number of games we have for the teams
      # TODO: if it was really unbalanced, punish them more for changes
      home_bonus_k = away_bonus_k = 0
      if home_games_played < 4
        home_bonus_k = 100
      elsif home_games_played < 8
        home_bonus_k = 50
      end

      if away_games_played < 4
        away_bonus_k = 100
      elsif away_games_played < 8
        away_bonus_k = 50
      end

      this_k = K

      newHomeELO = (home_mmr + (this_k + home_bonus_k) / num_games_played * (home_wins - exp_home_win) + 0).floor # Emphatic victor bonus = 0 for now
      newAwayELO = (away_mmr + (this_k + away_bonus_k) / num_games_played * (away_wins - exp_away_win) + 0).floor # Emphatic victor bonus = 0 for now
      puts "Home: #{home_team.teamname} ( #{home_mmr} --> #{newHomeELO} )   Expected: #{exp_home_win}  Actual: #{home_wins}"
      puts "Away: #{away_team.teamname} ( #{away_mmr} --> #{newAwayELO} )   Expected: #{exp_away_win}  Actual: #{away_wins}"
      puts "K: #{this_k + home_bonus_k} | #{this_k + away_bonus_k}"
      puts "-----------------"
      @team_elos[home_team.id] = newHomeELO
      @team_elos[away_team.id] = newAwayELO
      elo_holder << {:match => match, :new_home_ELO => newHomeELO, :new_away_ELO => newAwayELO}
    end


    puts "\n\nDid I do OK? Type 'yes charles' if you'd like to insert these. Anything else will breakout. "
    ok_to_insert = STDIN.gets.chomp == "yes charles"
    raise "Later days!" if !ok_to_insert

    # commit the data
    elo_holder.each do |info|
      match = info[:match]

      home = match.home_team
      home.mmr = @team_elos[home.id]
      home.save!

      away = match.away_team
      away.mmr = @team_elos[away.id]
      away.save!

      match.mmr_processed = true
      match.save!
    end
  end

  desc "Do RPI ranking and output people"
  task :rpi => :environment do
    puts "First pass, finding teams and calculating wins"

    puts "Season?"
    season_id = STDIN.gets.chomp.to_i
    season = Season.find(season_id)
    teams = season.teams # TODO: optimize dual lookup with below?
    matches = season.matches.scored.includes(:home_team, :away_team) # TODO: scored scope added, should remove code below

    @total_scores = {}
    @total_matches = {}
    matches.each do |match|
      next if match.home_score.to_i == 0 && match.away_score.to_i == 0
      @total_scores[match.home_team_id] = @total_scores[match.home_team_id].to_i + match.home_score.to_i
      @total_scores[match.away_team_id] = @total_scores[match.away_team_id].to_i + match.away_score.to_i
      @total_matches[match.home_team_id] = @total_matches[match.home_team_id].to_i + match.home_score.to_i + match.away_score.to_i
      @total_matches[match.away_team_id] = @total_matches[match.away_team_id].to_i + match.home_score.to_i + match.away_score.to_i
    end

    @win_percents = @total_scores.map do |team_id, wins|
      [team_id, wins.to_f / @total_matches[team_id].to_f]
    end

    # Turn this back into a hash
    @win_percents = Hash[@win_percents.map {|k, v| [k, v] }]

    puts @win_percents.inspect

    # @win_percents.sort_by!{|k,v| v}.reverse

    # @win_percents.each do |k,v|
    #   puts "#{teams.find(k).teamname}: #{v}"
    # end

    @opponent_opponent_win_percents = {}
    @opponent_win_percents = {}

    @win_percents.each do |team_id, win_pct|
      # puts "TEAM: #{team_id}"

      # Find each match this team had and calculate the winning percentage for their opponent
      teams_matches = matches.select {|m| m.away_team_id == team_id || m.home_team_id == team_id }
      opp_opp_win_pcts = []
      opp_win_pcts = teams_matches.map do |match|
        # exclude games not yet played or scored...TODO: exclude forfeit?
        next if match.away_score.to_i == 0 && match.home_score.to_i == 0

        # puts "working match #{match.id}: #{match.home_team_id} - #{match.away_team_id}"

        opponent_id = match.away_team_id == team_id ? match.home_team_id : match.away_team_id
        # puts "opp: #{opponent_id}"

        # Compute this opponent's OWP (for OOWP). All teams are valid for this (including self) so do it separate from the check below
        opponent_matches_all = matches.select {|m| (m.away_team_id == opponent_id || m.home_team_id == opponent_id )}
        opp_opp_win_pct = opponent_matches_all.map { |m| m.away_team_id == opponent_id ? @win_percents[m.home_team_id] : @win_percents[m.away_team_id] }
        # puts "opp_opp_pct:"
        # puts opp_opp_win_pct.inspect
        opp_opp_win_pcts << opp_opp_win_pct.inject{ |sum, el| sum + el }.to_f / opp_opp_win_pct.size

        # OWP calculated as the opponent's winning percentage ignoring ANY games against the current team
        opponent_matches = matches.select {|m| (m.away_team_id == opponent_id || m.home_team_id == opponent_id) && m.away_team_id != team_id && m.home_team_id != team_id }
        # puts "opp match count: #{opponent_matches.size}"
        opponent_game_count = opponent_matches.sum{ |m| m.away_score.to_i } + opponent_matches.sum{ |m| m.home_score.to_i }
        # puts "opp game count: #{opponent_game_count}"
        opponent_wins = opponent_matches.sum{ |m| m.away_team_id == opponent_id ? m.away_score.to_i : m.home_score.to_i }
        # puts "opp wins: #{opponent_wins}"
        opponent_game_count == 0 ? nil : opponent_wins / opponent_game_count
      end
      # puts "opp win pcts"
      opp_win_pcts.inspect

      opp_win_pcts.compact!
      opp_win_pct = opp_win_pcts.inject{ |sum, el| sum + el }.to_f / opp_win_pcts.size unless opp_win_pcts.empty?
      @opponent_win_percents[team_id] = opp_win_pct if opp_win_pct

      # finally, calculate final OOWP
      @opponent_opponent_win_percents[team_id] = opp_opp_win_pcts.compact.inject{ |sum, el| sum + el }.to_f / opp_opp_win_pcts.size
    end

    puts "------------"
    puts @opponent_win_percents.inspect
    puts "------------"
    puts @opponent_opponent_win_percents.inspect

    # compute the final RPIs?
    @rpis = {}
    @win_percents.each do |team_id, wp|
      if wp.nil? || @opponent_win_percents[team_id].nil? || @opponent_opponent_win_percents[team_id].nil?
        puts "Skipping team: #{team_id} as a needed value was nil"
        next
      end
      @rpis[team_id] = wp * 0.25 + @opponent_win_percents[team_id] * 0.50 + @opponent_opponent_win_percents[team_id] * 0.25
    end

    # Output
    @rpis.sort_by { |k,v| v * -1}.each do |k, v|
      next if k.nil?
      puts "#{teams.find(k).teamname}: #{v}" rescue next
    end

    puts "------------------"

    # Output
    @rpis.sort_by do |k,v|
      teams.find(k).mmr * v * -1 rescue -1
    end.each do |k, v|
      next if k.nil?
      team = teams.find(k) rescue next
      puts "#{team.teamname}: #{team.mmr * v} (#{v}) (#{team.mmr})"
    end
  end

  task :mail => :environment do
    @players = Player.where("id > ?", 6370)
    playerz = Player.find(205)
    @players.each do |player|
      unless player.email.nil?
        UserMailer.season4_reminder(player, playerz).deliver
      end
    end
  end

  task :playoff_mail => :environment do
    @seasonz = Season.where(:id => [44, 45, 46])

    @seasonz.each do |season|
      season.teams.each do |team|
        unless team.captain.nil?
          UserMailer.playoff_email(team.captain).deliver
        end
      end
    end
  end

  task :scheduler => :environment do
    puts "What season id?"
    season_id = STDIN.gets.chomp.to_i
    @season = Season.find(season_id)

    puts "enter a division or 'all' to do all"
    division = STDIN.gets.chomp
    ts = TeamSeason.where(:season_id => @season.id, :paid => true)
    ts = ts.where(:division => division) unless division == "all"
    raise "no paid teams found" unless ts.count > 0

    puts "what week are we generating?"
    week = STDIN.gets.chomp.to_i
    if week < 1 || week > 15
      raise "This appears to be an invalid week"
    end

    if Match.where(:season_id => @season.id, :week => week).where("away_team_id IN (:team_ids) OR home_team_id IN (:team_ids)", {:team_ids => ts.pluck(:team_id)}).exists?
      raise "Teams that would be scheduled are already scheduled for this week"
    end

    puts "Now, need a date for these matches (i.e. 2014-03-06, yyyy-mm-dd) in that EXACT format"
    date = STDIN.gets.chomp

    puts "Finally, timezone (i.e. -0400 for EDT, +0200 for CEST) in that EXACT format"
    tz = STDIN.gets.chomp

    matchup_array = []
    object = Object.new
    @matches = Match.where(:season_id => @season.id)
    @matches.each do |match|
      if match.home_team_id && match.away_team_id
        matchup_array.push match.home_team_id + match.away_team_id
      end
    end

    teams_by_division = ts.all.group_by(&:division)

    teams_by_division.each do |division, team_seasons|
      count = 0
      until test_matchups(team_seasons, matchup_array, division, week, date, @season, tz) == 0 || count == 30
        count = count + 1
        puts "Failed on attempt number #{count}"
      end
      if count == 30
        puts "#{division} could not find a suitable match"
      end
    end

  end

  def test_matchups(team_seasons, matchup_array, division, week, date, season, tz)
      team_array = []
      test_matches = []


      team_seasons.each do |tz|
        team_array.push(tz.team_id)
      end

      length = team_array.length/2
      i = 0
      while i < length
        this = team_array.sample(2)
        team_array = team_array - this
        test_matches.push(this)
        i += 1
      end

      puts "Testing matches for #{division}"
      fail = 0
      test_matches.each do |test_match|
        puts "#{test_match}"
        if matchup_array.include? test_match[0] + test_match[1]
          puts "#{test_match[0]} and #{test_match[1]} may have already played!}"
          return 1
        end
      end 

      test_matches.each do |test_match|
        time = rand(3) === 0 ? "22:00:00" : "20:30:00"
        datetime = "#{date} #{time} #{tz}"
        match = season.matches.build
        match.week = week
        match.home_team_id = test_match[0]
        match.away_team_id = test_match[1]
        match.date = datetime
        match.reschedule_time = datetime
        match.save!
      end
      puts "Success!"
      return 0

  end

  task :swap_teams => :environment do
    puts "This tool allows you to handle dropped teams in a season"
    puts "we'll remove the given team and swap another team into their divison in their place"
    puts ""
    puts "First, input the season we are doing surgery on"
    season_id = STDIN.gets.chomp.to_i
    @season = Season.find(season_id)

    puts "Next, input the team id which is being dropped from this season"
    dropped_team_id = STDIN.gets.chomp.to_i
    drop_ts = TeamSeason.find_by_season_id_and_team_id(season_id, dropped_team_id)
    raise "Not Found" unless drop_ts

    puts "Finally, give the team id that will be taking their place in the schedule and division: #{drop_ts.division}"
    replace_team_id = STDIN.gets.chomp.to_i
    replace_ts = TeamSeason.find_by_season_id_and_team_id(season_id, dropped_team_id)
    raise "Not Found" unless replace_ts

    # We are going to move over attributes to the stale TS, then delete
    # This will keep the ts_id which means scheduling should keep them in the same order
    drop_ts.paid = replace_ts.paid
    drop_ts.price_paid_cents = replace.price_paid_cents
    drop_ts.checked_in = replace_ts.checked_in
    drop_ts.created_at = replace_ts.created_at
    drop_ts.team_id = replace_ts.team_id
    drop_ts.save!

    replace_ts.destroy
    puts "It is so"
  end

  task :merge_teams => :environment do
    puts "This tool allows you to merge duplicate teams"
    puts "all their matches and players will be condensed. NOTE: we cannot recomputed MMR so that will remain unchanged"
    puts ""
    puts "First, input the team id that you want to remain"
    team_id = STDIN.gets.chomp.to_i
    team = Team.find(team_id)
    raise "Not Found" unless team

    puts "Next, input the team id which will be merged and removed"
    dup_team_id = STDIN.gets.chomp.to_i
    dup_team = Team.find(dup_team_id)
    raise "Not Found" unless dup_team

    puts "You are about to mege '#{dup_team.teamname}' (MMR: #{dup_team.mmr}) into '#{team.teamname}' (MMR: #{team.mmr}) ...are you sure? (yes charles)"
    ok_to_insert = STDIN.gets.chomp == "yes charles"
    raise "Later days!" unless ok_to_insert


    TeamSeason.where(:team_id => dup_team_id).update_all(:team_id => team_id)
    Match.where(:home_team_id => dup_team_id).update_all(:home_team_id => team_id)
    Match.where(:away_team_id => dup_team_id).update_all(:away_team_id => team_id)
    team.players << (dup_team.players - team.players)

    dup_team.reload.destroy

    puts "It is so"
  end

  task :pull_inhousegames => :environment do    

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
            @inhouse_game.update_attributes(:hero_id => player["hero_id"], :kills => player["kills"], :last_hits => player["last_hits"], :leaver_status => player["leaver_status"], :level => player["level"], :tower_damage => player["tower_damage"], :xp_per_min => player["xp_per_min"], :player_slot => player["player_slot"])
            @inhouse_game.save!
          end
        end
      end
    end

  end

  task :compile_inhouse => :environment do

    @accounts = Inhousegame.uniq.pluck(:account_id)

    @accounts.each do |account|
      @games = Inhousegame.where(:account_id => account, :checked => false)

      if !@games.empty?
        puts "hey"

        @wins = 0
        @kills = 0
        @deaths = 0
        @assists = 0
        @games_played = 0

        @player = Player.find_by_steam32id(account)

        unless @player
          @profiles = Dota.profiles(account + 76561197960265728.to_i)

          @profiles.each do |profile|
            @player = Player.new
            @player.steam32id = account
            @player.steamid = account + 76561197960265728.to_i
            @player.name = profile.raw_profile["personaname"]
            @player.save!
          end

        end

        @games.each do |game|
          if (game.player_slot < 5 && game.radiant_win === 1) || (game.player_slot > 4 && game.radiant_win != 1)
            @wins = @wins + 1
          end

          @kills = @kills + game.kills
          @deaths = @deaths + game.deaths
          @assists = @assists + game.assists
          @games_played = @games_played + 1

          game.checked = true
          game.save!

        end

        @player_exists = Inhouseleaderboard.find_by_player_id(@player.id)

        if !@player_exists
          @inhouseleaderboard_record = Inhouseleaderboard.new
        else
          @inhouseleaderboard_record = @player_exists
        end

        @inhouseleaderboard_record.account_id = account
        @inhouseleaderboard_record.player_id = @player.id
        @inhouseleaderboard_record.season_id = 1
        @inhouseleaderboard_record.wins = @wins + @inhouseleaderboard_record.wins.to_i
        @inhouseleaderboard_record.games_played = @games_played + @inhouseleaderboard_record.games_played.to_i
        @inhouseleaderboard_record.kills = @kills + @inhouseleaderboard_record.kills.to_i
        @inhouseleaderboard_record.deaths = @deaths + @inhouseleaderboard_record.deaths.to_i
        @inhouseleaderboard_record.assists = @assists + @inhouseleaderboard_record.assists.to_i
        @inhouseleaderboard_record.save!
      end

    end

  end


end