class Attachment < ActiveRecord::Base
 belongs_to :match
 belongs_to :player
 has_attached_file :attachment
 validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/
 validates_attachment_size :attachment, :less_than => 2.megabytes
end