class ChangeColumnNamesAddInactiveTeamColumn < ActiveRecord::Migration

  def change
  	rename_column :matches, :twitch, :caster_id
  	add_column :teams, :active, :boolean
  	add_column :seasons, :registration_open, :boolean
  	add_column :posts, :author_id, :integer
  	add_column :posts, :create_date, :datetime
    add_column :matches, :forfeit, :boolean    

	create_table :MatchComments do |t|
	  t.integer :match_id
	  t.integer :player_id
	  t.text :comment
	  t.datetime :create_date
	end

  end
end
