require 'acts_as_paranoid_versioned'
class Milestone < ActiveRecord::Base
acts_as_simile_timeline_event(
    :fields =>
    {
      :start       => :startDate,
      :title       => :name,
      :end        =>  :endDate,
      :description => :timeline_details,
      :isDuration => false
    }
  )
  
  has_many :tasks, :dependent => :destroy
  belongs_to :project 
#  belongs_to :program, :through => :project
  belongs_to :milestone_status
  
  acts_as_paranoid_versioned

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

  def startDate
    "#{self.target_date}"
  end
  
   def endDate
    ""
  end
  
 def timeline_details
   "#{self.description}"
 end
  def tasks_count
    return tasks.count
  end

  def parent_program
    return self.project.program.name
  end
end