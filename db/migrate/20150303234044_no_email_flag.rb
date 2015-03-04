class NoEmailFlag < ActiveRecord::Migration
  def change
    add_column :players, :receive_emails, :boolean, default: true
    add_column :players, :twitter, :string
  end
end
