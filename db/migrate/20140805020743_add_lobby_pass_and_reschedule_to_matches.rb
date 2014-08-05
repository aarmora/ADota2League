class AddLobbyPassAndRescheduleToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :lobby_password, :string
    add_column :matches, :reschedule_time, :datetime
    add_column :matches, :reschedule_proposer, :integer
    add_column :matchcomments, :auto_generated, :boolean, :null => false, :default => false
  end
end
