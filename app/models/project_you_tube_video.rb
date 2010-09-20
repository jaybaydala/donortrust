class ProjectYouTubeVideo < ActiveRecord::Base
  belongs_to :project, :touch => true
  validates_presence_of :project_id, :you_tube_id
  validate do |me|
    unless me.project( true )
      me.errors.add :project_id, 'does not exist'
    end
  end
end
