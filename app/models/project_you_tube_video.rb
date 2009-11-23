class ProjectYouTubeVideo < ActiveRecord::Base
  belongs_to :project, :touch => true

  validates_presence_of :project_id, :you_tube_id
end
