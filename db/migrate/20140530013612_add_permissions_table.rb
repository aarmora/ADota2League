class AddPermissionsTable < ActiveRecord::Migration
  def change

    create_table :permissions do |t|
      t.integer :player_id
      t.string :permission_mode#, :enum, :limit => [:site, :organization, :seasons, :division]
      t.integer :organization_id
      t.integer :season_id
      t.string :division
    end

    add_index :permissions, :player_id

  end
end