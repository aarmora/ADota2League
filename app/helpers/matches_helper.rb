module MatchesHelper
  def select_teams_for_season_week_with_current_team(season_id, week, current_team)
    other_teams = [["", ""]] + Team.available_for_season_and_week(season_id, week)
    puts [current_team.id, current_team.teamname] if current_team
    other_teams += [[current_team.id, current_team.teamname]] if current_team
    other_teams.compact.uniq.map { |a| [a[0].to_s, a[1].to_s] }.sort_by { |a| a[1] }
  end

  def select_teams_for_new_match
    other_teams = [["", ""]] + Team.all
    other_teams.compact.uniq.map { |a| [a[0].to_s, a[1].to_s] }.sort_by { |a| a[1] }
  end

end
