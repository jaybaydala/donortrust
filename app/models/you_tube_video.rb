class YouTubeVideo < ActiveRecord::Base
  has_many :project_you_tube_videos
  
  validates_presence_of :you_tube_reference
  validates_uniqueness_of :you_tube_reference
  
  attr_accessor :extra_tags
  
end
