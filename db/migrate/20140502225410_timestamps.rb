class Timestamps < ActiveRecord::Migration
  def change
    add_column :team_seasons, :created_at, :datetime
    add_column :team_seasons, :updated_at, :datetime

    add_column :teams, :created_at, :datetime
    add_column :teams, :updated_at, :datetime
  end
end
