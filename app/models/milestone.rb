class Milestone < ActiveRecord::Base
  acts_as_versioned

  has_many :tasks, :dependent => :destroy
  has_many :milestone_versions
  belongs_to :project
#  belongs_to :program, :through => :project
  belongs_to :milestone_status

  #attr_reader

  #:foreign_key => :project_id
  #:association_foreign_key

  validates_presence_of :milestone_status_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id
  validates_presence_of :description

  validate do |milestone|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless milestone.project( true )
      milestone.errors.add :project_id, 'does not exist'
    end
    unless milestone.milestone_status( true )
      milestone.errors.add :milestone_status_id, 'does not exist'
    end
  end

  def tasks_count
    return tasks.count
  end

  def parent_program
    return self.project.program.name
  end

  def version_count
    return milestone_versions.count
  end
end