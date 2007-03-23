class ProjectStatus < ActiveRecord::Base

  has_many :projects 
  has_many :project_histories

  validates_presence_of :status_type
  validates_uniqueness_of :status_type

end