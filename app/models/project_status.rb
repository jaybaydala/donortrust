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
    find(:first, :conditions => ["name LIKE ?", "Started"])
  end
  def self.completed
    find(:first, :conditions => ["name LIKE ?", "Completed"])
  end
  def self.public
    find(:all, :conditions => ["name LIKE ? OR name LIKE ?", "Started", "Completed"])
  end
  def self.public_ids
    self.public.map{|ps| ps.id }
  end
end