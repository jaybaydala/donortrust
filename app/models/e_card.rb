class ECard < ActiveRecord::Base
  file_column :file
  
  validates_presence_of :name
  
end
