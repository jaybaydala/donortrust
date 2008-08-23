class ProjectYouTubeVideo < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project_id, :you_tube_id
end
