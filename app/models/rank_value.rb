class RankValue < ActiveRecord::Base
   has_many :ranks
   
  file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  validates_presence_of :file
  
  validates_numericality_of :rank_value
  validates_presence_of :rank_value, :if => :check_validation?
    
  protected 
  def check_validation?
    if rank_value != nil
      rank_value <= 4 
    end
  end
    
  def validate
    if rank_value != nil
      errors.add(:rank_value, "Rank must be between 0 and 4" ) if rank_value > 4 or rank_value < 0 #or rank = nil
    end
  end  
end
