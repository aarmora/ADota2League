class AddCheckedInToTeamSeason < ActiveRecord::Migration
  def change
    add_column :team_seasons, :checked_in, :boolean, :null => false, :default => false
  end
end
