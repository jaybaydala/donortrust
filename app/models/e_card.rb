class ECard < ActiveRecord::Base
  file_column :small,     :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  file_column :medium,    :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  file_column :large,     :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  file_column :printable, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  
  validates_presence_of :name
  
end
