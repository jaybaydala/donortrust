class QuickFact < ActiveRecord::Base
    
  belongs_to :quick_fact_type
 
  validates_presence_of :name 
  validates_presence_of :type
  validates_presence_of :quick_fact_type_id
  
  def summarized_description(length = 50)
    return unless self.description?
    if @summarized_description.nil?
      @summarized_description = description(:plain).split($;, length+1)
      @summarized_description.pop
      @summarized_description = @summarized_description.join(' ')
      @summarized_description += (@summarized_description[-1,1] == '.' ? '..' : '...')
    end
    @summarized_description
  end    

end
