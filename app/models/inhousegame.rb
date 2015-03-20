class Inhousegame < ActiveRecord::Base
  	has_one :player, :foreign_key => "steam32id", :primary_key => "account_id"
end
