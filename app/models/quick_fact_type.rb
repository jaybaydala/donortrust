class QuickFactType < ActiveRecord::Base
  
  has_many :quick_facts
    
  validates_presence_of     :name
  validates_uniqueness_of   :name
  
end
