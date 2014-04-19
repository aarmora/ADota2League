class PlayerComments < ActiveRecord::Migration
  def change

  	create_table :player_comments do |t|
  	  t.integer :commenter_id
  	  t.integer :recipient_id
  	  t.text :comment
  	  t.timestamps
  	end

  	Player.all.each do |player|  	
			player.freeagentflag = false
			player.save!  		
  	end

    rename_column :player_votes, :recepient_id, :recipient_id
    rename_column :player_votes, :voter_id, :endorser_id

  end
end
