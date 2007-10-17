class Rank < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :rank_type 
   
   
  validates_presence_of :rank_type_id
  validates_presence_of :rank
  validates_presence_of :rank, :if => :check_validation?
  validates_numericality_of :rank 
  
  protected 
  def check_validation?
    if rank != nil
      rank <= 4 
    end
  end
    
  def validate
    if rank != nil
      errors.add(:rank, "Rank must be between 0 and 4" ) if rank > 4 or rank < 0 #or rank = nil
    end
  end  
end
 
  
  
