class ProjectPoi < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_presence_of :project_id, :name, :email
end
