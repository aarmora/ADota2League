# This migration comes from mad_chatter (originally 20130416051633)
class CreateMadChatterRooms < ActiveRecord::Migration
  def change
    create_table :mad_chatter_rooms do |t|
      t.string :name
      t.references :owner

      t.timestamps
    end
  end
end
