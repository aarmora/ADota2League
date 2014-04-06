class Post < ActiveRecord::Base	
  belongs_to :author, :class_name => "Player"  
  attr_accessible :text, :title, :author_id
end
