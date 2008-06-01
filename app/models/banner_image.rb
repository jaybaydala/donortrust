class BannerImage < ActiveRecord::Base
  
  file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")

  validates_numericality_of :model_id  

end
