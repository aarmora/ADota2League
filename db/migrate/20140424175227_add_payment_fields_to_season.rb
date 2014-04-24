class AddPaymentFieldsToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :late_fee_start, :datetime
    add_column :seasons, :price_cents, :integer, :null => false, :default => 0
    add_column :seasons, :late_price_cents, :integer, :null => false, :default => 0

    # Add a number which just groups seasons together. Teams may only register for one season within the group
    add_column :seasons, :exclusive_group, :integer, :null => true, :default => nil

    add_column :team_seasons, :paid, :boolean, :null => false, :default => false
    add_column :team_seasons, :price_paid_cents, :integer, :null => false, :default => 0

    # TODO: Add a payment table for archive and verification purposes?
  end
end
