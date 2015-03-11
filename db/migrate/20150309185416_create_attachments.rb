class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :match_id
      t.integer :player_id, null: false
      t.attachment :attachment
    end
  end
end
