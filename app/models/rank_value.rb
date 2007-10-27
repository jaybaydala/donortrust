class RankValue < ActiveRecord::Base
   has_many :ranks
   
   file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
   validates_presence_of :file
    
 validates_presence_of :rank_value, :if => :check_validation?
  validates_numericality_of :rank_value
  
  protected 
  def check_validation?
    if rank != nil
      rank <= 4 
    end
  end
    
  def validate
    if rank != nil
      errors.add(:rank_value, "Rank must be between 0 and 4" ) if rank > 4 or rank < 0 #or rank = nil
    end
  end  
end
