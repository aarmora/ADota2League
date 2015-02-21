namespace :db do
  desc "Remove Players and teams of little consquence"
  task :prune => :environment do
    puts("Looking for old teams")
    tids = Team.where("updated_at < ?", Time.now - 6.months).pluck(:id)
    puts("#{tids.size} old teams")

    # Seasons 1,2,7 didn't have concepts of paid / unpaid so avoid pruning those
    tids_in_season = TeamSeason.where(season_id: [1,2,7]).pluck(:participant_id)

    tids_in_season += TeamSeason.where(participant_type: "Team", paid: true).pluck(:participant_id)
    tids_to_prune = (tids - tids_in_season)
    puts("Will prune #{tids_to_prune.size} old teams without a paid season")

    puts("Looking for old players")
    ids = Player.where("updated_at < ?", Time.now - 6.months).pluck(:id)
    pids_on_teams = Player.connection.select_values("SELECT `player_id` FROM `players_teams`")
    pids_on_teams_adj = Player.connection.select_values("SELECT `player_id` FROM `players_teams` where `team_id` NOT IN (#{tids_to_prune.join(',')})")

    puts("Would prune #{(ids - pids_on_teams).size} players")
    puts("Will prune #{(ids - pids_on_teams_adj).size} players after removing teams")

    puts "Proceed?"
    resp = STDIN.gets.chomp

    if resp == "yes"
      puts ("Pruning...")
      # saftey
      # Team.find(tids_to_prune).destroy_all
      # Player.find(ids - pids_on_teams_adj).destroy_all
    end

  end

end