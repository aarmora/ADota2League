class AddRulesToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :rules, :text
  end
end
