class YouTubeVideo < ActiveRecord::Base
  validates_presence_of :you_tube_reference
  validates_uniqueness_of :you_tube_reference
end
