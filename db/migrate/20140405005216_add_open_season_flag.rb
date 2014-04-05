class AddOpenSeasonFlag < ActiveRecord::Migration
  def change
	Team.all.each do |team|
		if team.team_seasons.count > 0
			team.active = true
			team.save!
		end
	end
	change_column :teams, :active, :boolean, :default => true
  end
end
