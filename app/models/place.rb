class Place < ActiveRecord::Base
  acts_as_tree :order=>"name"
  file_column :file
  
  belongs_to :place_type
  belongs_to :rss_feed
  belongs_to :sector
  has_many :quick_fact_places
  has_many :projects
  has_many :place_sectors
  
end
