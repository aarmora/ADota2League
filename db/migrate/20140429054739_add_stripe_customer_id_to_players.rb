class AddStripeCustomerIdToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :stripe_customer_id, :string
  end
end
