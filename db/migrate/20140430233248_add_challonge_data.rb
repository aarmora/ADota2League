class AddChallongeData < ActiveRecord::Migration
  def change
    add_column :seasons, :challonge_id, :integer
    add_column :seasons, :challonge_url, :string
    add_column :seasons, :challonge_type, :string

    add_column :matches, :challonge_id, :integer
  end
end
