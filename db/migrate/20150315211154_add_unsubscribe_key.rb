class AddUnsubscribeKey < ActiveRecord::Migration
  def change
    add_column :players, :unsubscribe_key, :string
  end
end
