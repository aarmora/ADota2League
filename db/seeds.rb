# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

200.times do |i|
  Player.create(name: "Player ##{i}")
end


# Admins
havoc = Player.create({name: "Havoc", steamid: "76561197969226815", steam32id: "8961087"}, :without_protection => true)
havoc.permissions.create(:permission_mode => "site")

32.times do |i|
  t = Team.create(name: "Team ##{i}")
  start = i * 5 + 1
  last = (i+1)* 5
  t.players << Player.find((start..last).to_a)
end

#
# Create in-progress seasons and registrations
#
rr = Season.create({start_date: Time.now - 1.month, title: "Round Robin", season_type: :round_robin, active: true}, :without_protection => true)
Team.first(12).each_with_index do |t, i|
  rr.team_seasons.create({division: i < 6 ? "1" : "2", participant: t, paid: true, checked_in: true}, :without_protection => true)
end
matches = [
  [[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]],
  [[1,3],[2,6],[5,4],[7,9],[8,12],[11,10]],
  [[1,4],[3,6],[5,2],[7,10],[9,12],[11,8]]
]
matches.each_with_index do |pairings, i|
  pairings.each do |pair|
    rr.matches.create({
      week: i + 1,
      date: Time.now - 1.month + i.week,
      home_participant: Team.find(pair[0]),
      away_participant: Team.find(pair[1]),
      home_score: 2,
      away_score: 1
    }, :without_protection => true)
  end
end


single = Season.create({title: "Single Elim", season_type: :single_elim, active: true, start_date: Time.now - 1.day}, :without_protection => true)
Team.first(13).each do |t|
  single.team_seasons.create({division: t.id, participant: t, paid: true, checked_in: true}, :without_protection => true)
end
single.setup_tournament_matches

double = Season.create({title: "Double Elim", season_type: :double_elim, active: true, start_date: Time.now - 1.day}, :without_protection => true)
Team.first(8).each do |t|
  double.team_seasons.create({division: t.id, participant: t, paid: true, checked_in: true}, :without_protection => true)
end
double.setup_tournament_matches
