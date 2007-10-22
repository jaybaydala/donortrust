class RankValue < ActiveRecord::Base
   file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
   validates_presence_of :file
    
end
