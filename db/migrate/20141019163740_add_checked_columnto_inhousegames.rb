class AddCheckedColumntoInhousegames < ActiveRecord::Migration
  def change
    add_column :inhousegames, :checked, :boolean, :null => false, :default => false

  end
end
