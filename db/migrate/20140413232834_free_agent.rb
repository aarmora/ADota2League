class FreeAgent < ActiveRecord::Migration
  def change
    create_table :player_votes do |t|
      t.integer :voter_id
      t.integer :recepient_id
      t.timestamps
    end
    
    add_column :seasons, :active, :integer   
    #Is this going to be the same as role?
    add_column :players, :bio, :text   
    add_column :players, :admin, :boolean   

  end
end
