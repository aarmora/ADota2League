namespace :dota do
  desc "Update our local games table from the DotA API"
  task :pull_games => :environment do
  	# NOTE: This might need to be run while no games are going on. Unclear if it returns in-progress matches
  	# NOTE: Dota API "matches" are really just single games AFAIK. That convolutes the notation a bit.
 
  	# For now assume the league id is 158...we may need multiple leagues later (get from std in)
  	league_id = 158
  	
  	# Get the last game in our table from this league
  	# NOTE: We do not have this mapping right now, so we're looking at all games :(
  	last_seen_id = Game.maximum(:steam_match_id)
  	last_start_id = nil
  	
  	puts "Working backwards from now to game #{last_seen_id}"
  	
  	begin
  	 puts "Pulling a batch of games starting at #{last_start_id}"
  	 history = Dota.history(:league_id => 158, :start_at_match_id => last_start_id)
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
  	 		m = Match.where(:away_team_id => [dire_team.id, radiant_team.id], :home_team_id => [dire_team.id, radiant_team.id]).first
  	 		# NOTE: This is time boxed, so the game should take place within a week of the scheduled match for auto-matching
  	 		if m && (Date.parse(m.start) - m.date.to_date).abs <= 8
  	 			game_entry.match_id = m.id
  	 			puts "Found matching match! #{m.id}"
  	 			# TODO: adjust MMR here based on results?
  	 		end
  	 	end
  	 	
  	 	game_entry.save!  	 	
  	 end
  	 
  	end while last_seen_id <= last_start_id
  end

  desc "Generate Matches for a given league and week"
  task :make_matches => :environment do
    puts "Making matches!"
  end
  
  desc "Adjust MMR for a given league and week based on results"
  task :mmr => :environment do
    puts "Adjusting MMRs!"
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
      puts "#{teams.find(k).teamname}: #{v}"
    end


  end

end