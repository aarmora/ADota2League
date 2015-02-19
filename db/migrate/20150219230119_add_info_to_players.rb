class AddInfoToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :real_name, :string
    add_column :players, :avatar, :string
    add_column :players, :country, :string
  end
end
