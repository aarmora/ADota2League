namespace :dota do
  desc "Update our local games table from the DotA API"
  task :pull_games => :environment do
  	# NOTE: This might need to be run while no games are going on. Unclear if it returns in-progress matches
 
  	# For now assume the league id is 158...we may need multiple leagues later (get from std in)
  	league_id = 158
  	
  	# Get the last game in our table from this league
  	# NOTE: We do not have this mapping right now, so we're looking at all games :(
  	last_seen_id = Game.maximum(:steam_match_id)
  	last_start_id = nil
  	
  	begin
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
  	 		start_time = Date.parse(m.start)
  	 		# NOTE: This is time boxed, so the game should take place within a week of the scheduled match for auto-matching
  	 		if m && (start_time - m.date.to_date).abs <= 8
  	 			game_entry.match_id = m.id
  	 			puts "Found matching match! #{m.id}"
  	 			# TODO: adjust MMR here based on results?
  	 		end
  	 	end
  	 	
  	 	game_entry.save!  	 	
  	 end
  	 
  	end while last_start_id 
  end

  desc "Generate Matches for a given league and week"
  task :make_matches => :environment do
    puts "Making matches!"
  end
  
  desc "Adjust MMR for a given league and week based on results"
  task :mmr => :environment do
    puts "Adjusting MMRs!"
  end
end