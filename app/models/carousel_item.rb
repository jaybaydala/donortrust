class CarouselItem < ActiveRecord::Base
  validates_presence_of :title, :title_image
  validates_attachment_size :title_image, :less_than => 10.megabyte,  :unless => Proc.new {|model| model.image }
  validates_attachment_content_type :title_image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png), :unless => Proc.new {|model| model.image } # the last 2 for IE
  validates_attachment_size :image, :less_than => 10.megabyte,  :unless => Proc.new {|model| model.image }
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png), :unless => Proc.new {|model| model.image } # the last 2 for IE

  has_attached_file :title_image, 
    :default_style => :original,
    :convert_options => { 
      :all => "-strip" # strips metadata from images, removing potentially private info
    },
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
  has_attached_file :image, 
    :default_style => :original,
    :convert_options => { 
      :all => "-strip" # strips metadata from images, removing potentially private info
    },
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
  

  def title_image_only?
    title_image? && !content? && !image? && !code?
  end
end