class Game < ActiveRecord::Base
  belongs_to :match
  # attr_accessible :title, :body
end
