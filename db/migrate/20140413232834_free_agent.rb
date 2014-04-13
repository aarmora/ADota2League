class FreeAgent < ActiveRecord::Migration
  def change
    create_table :player_votes do |t|
      t.integer :voter_id
      t.integer :recepient_id

      t.timestamps
    end

  end
end
