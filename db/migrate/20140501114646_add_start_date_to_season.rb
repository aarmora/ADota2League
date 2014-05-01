class AddStartDateToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :start_date, :datetime
    add_column :seasons, :description, :text
  end
end
