class AddPlayerSlottoInhousegames < ActiveRecord::Migration
  def change
    add_column :inhousegames, :player_slot, :integer

  end
end
