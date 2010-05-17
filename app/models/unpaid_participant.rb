class UnpaidParticipant < ActiveRecord::Base
  
  image_column  :picture,
                :versions => { :thumb => "100x100", :full => "200x200"  },
                :filename => proc{|inst, orig, ext| "participant_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/participant_pictures"
                
   validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true

  IMAGE_SIZES = {
    :full => {:width => 200, :height => 200, :modifier => ">"},
    :thumb => {:width => 100, :height => 100, :modifier => ">"}
  }
  has_attached_file :image, :styles => Hash[ *IMAGE_SIZES.collect{|k,v| [k, "#{v[:width]}x#{v[:height]}#{v[:modifier]}"] }.flatten ], 
    :default_style => :normal,
    :whiny_thumbnails => true,
    :convert_options => { 
      :all => "-strip" # strips metadata from images, removing potentially private info
    },
    :default_url => "/images/dt/icons/users/:style/missing.png",
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
  validates_attachment_size :image, :less_than => 1.megabyte
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png) # the last 2 for IE
                
end