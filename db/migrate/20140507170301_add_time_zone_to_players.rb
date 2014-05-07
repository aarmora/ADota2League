class AddTimeZoneToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :time_zone, :string
  end
end
