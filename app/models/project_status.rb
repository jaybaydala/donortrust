class ProjectStatus < ActiveRecord::Base
  acts_as_paranoid
  has_many :projects

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description

  def project_count
    return projects.count
  end
  
  def self.started
    find(:first, :conditions => {:name => "Started"})
  end
end