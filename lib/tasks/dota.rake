namespace :dota do
  desc "Update our local games table from the DotA API"
  task :pull_games => :environment do
  	# NOTE: This might need to be run while no games are going on. Unclear if it returns in-progress matches
  	# NOTE: Dota API "matches" are really just single games AFAIK. That convolutes the notation a bit.

  	puts "What season id?"
    season_id = STDIN.gets.chomp.to_i
    @season = Season.find(season_id)
  	league_id = @season.league_id
    raise "Season does not have dota league id set" unless league_id

  	# Get the last game in our table from this league
  	# NOTE: We do not have this mapping right now, so we're looking at all games :(
  	last_seen_id = Game.where(:match_id => @season.matches.pluck(:id)).maximum(:steam_match_id)
  	last_start_id = nil

  	puts "Working backwards from now to game #{last_seen_id}"

  	begin
  	 puts "Pulling a batch of games starting at #{last_start_id}"
  	 history = Dota.history(:league_id => league_id, :start_at_match_id => last_start_id)
  	 matches = history.matches
  	 break if matches.empty?
  	 matches.each do |match|
  	 	last_start_id = match.id
  	 	break if last_start_id <= last_seen_id

  	 	# Double check it doesn't exist, just in case...I don't think we'd want that
  	 	next if Game.where(:steam_match_id => match.id).exists?

  	 	# We haven't seen this match yet, let's fetch the details and insert it
  	 	dota_match = Dota.match(match.id)

  	 	# Don't save it yet, let's see if we can find the match
  	 	game_entry = Game.new(
  	 		:steam_match_id => dota_match.id,
  	 		:dire_team_id => dota_match.raw_match["dire_team_id"],
  	 		:dire_team_name => dota_match.raw_match["dire_name"],
  	 		:radiant_team_id => dota_match.raw_match["radiant_team_id"],
  	 		:radiant_team_name => dota_match.raw_match["radiant_name"],
  	 		:radiantwin => dota_match.raw_match["radiant_win"]
  	 	)

  	 	puts "Processing #{game_entry[:radiant_team_name]} vs. #{game_entry[:dire_team_name]}"

  	 	# Try to match the team ids from steam to those in our database
  	 	dire_team = Team.find_by_dotabuff_id(game_entry.dire_team_id)
  	 	radiant_team = Team.find_by_dotabuff_id(game_entry.radiant_team_id)
  	 	if dire_team && radiant_team
  	 		m = Match.where(:season_id => @season.id, :away_team_id => [dire_team.id, radiant_team.id], :home_team_id => [dire_team.id, radiant_team.id]).first
  	 		# NOTE: This is time boxed, so the game should take place within a week of the scheduled match for auto-matching
  	 		if m && (Date.parse(m.start) - m.date.to_date).abs <= 8
  	 			game_entry.match_id = m.id
  	 			puts "Found matching match! #{m.id}"
  	 			# TODO: adjust MMR here based on results?
  	 		end
  	 	else
        puts "Unable to find teams in DB for match. Got Dire: #{dire_team} Radiant: #{radiant_team}...skipping"
      end

  	 	game_entry.save! # Save the game anyways as we might not be able to process it again, we can come back later and clean this up if needed
  	 end

  	end while last_seen_id <= last_start_id
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
        match.games.each do |game|
          if game.radiantwin === "true" || game.radiantwin === true
            team = Team.find_by_dotabuff_id(game.radiant_team_id)
          else
            team = Team.find_by_dotabuff_id(game.dire_team_id)
          end

          if team == home_team
            home_wins += 1
          elsif team == away_team
            away_wins += 1
          end
        end

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
    @players = Player.all
    @players.each do |player|
      #player = Player.find(205)
      unless player.email.nil?
        UserMailer.season4_reminder(player).deliver
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

    puts "Now, need a date for these matches (i.e. 2014-03-06) in that EXACT format"
    date = STDIN.gets.chomp

    puts "Finally, timezone (i.e. -0400 for EDT, +0100 for CEST) in that EXACT format"
    tz = STDIN.gets.chomp


    teams_by_division = ts.all.group_by(&:division)
    teams_by_division.each do |division, team_seasons|
      puts "Creating matches for division #{division}"
      schedule = Rubin.new(team_seasons.sort_by(&:id).map(&:team_id))
      schedule.each_matchup do |home, away, round_num|
        next unless round_num == week
        # TODO: check existing matches and throw a warning if we are scheduling teams to play each other again
        time = rand(2) === 0 ? "20:30:00" : "22:00:00"
        datetime = "#{date} #{time} #{tz}"
        match = @season.matches.build
        match.week = week
        match.home_team_id = home
        match.away_team_id = away
        match.date = datetime
        match.save!
      end
    end
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
end