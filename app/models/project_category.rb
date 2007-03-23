class ProjectCategory < ActiveRecord::Base

  has_many :projects 
  has_many :project_histories

  validates_presence_of :description
  validates_uniqueness_of :description

end
