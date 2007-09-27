class Rank < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :rank_type 
   
  validates_presence_of :rank_type
  validates_presence_of :rank, :if => :check_validation?, :message => "Rank must be between 0 and 100"
  validates_numericality_of :rank 
  
  protected 
  def check_validation?
    rank <= 100
  end
  
  def validate  
    errors.add(:rank, "Rank must be between 0 and 100" ) if rank > 100 or rank < 0
  end
  
end
