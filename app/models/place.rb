class Place < ActiveRecord::Base
  
  acts_as_tree :order=>"name"
  
  belongs_to :place_type
  has_many :quick_fact_places
  
end
