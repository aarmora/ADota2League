# This migration comes from mad_chatter (originally 20130416054024)
class CreateMadChatterMessages < ActiveRecord::Migration
  def change
    create_table :mad_chatter_messages do |t|
      t.string :text
      t.string :html
      t.references :room
      t.references :author

      t.timestamps
    end
  end
end
