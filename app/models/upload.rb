class Upload < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :file
  
  has_attached_file :file,
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
end
