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
    active
  end
  def self.active
    find(:first, :conditions => ["name LIKE ?", "Active"])
  end
  def self.completed
    find(:first, :conditions => ["name LIKE ?", "Completed"])
  end
  def self.public_statuses
    find(:all, :conditions => ["name LIKE ? OR name LIKE ?", "Active", "Completed"])
  end
  def self.public_ids
    self.public_statuses.map(&:id)
  end
end