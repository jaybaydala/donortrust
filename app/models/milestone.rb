class Milestone < ActiveRecord::Base
  has_many :milestone_histories
  has_many :tasks
  belongs_to :project
  belongs_to :milestone_category
  belongs_to :milestone_status
  belongs_to :measure

  #:foreign_key => :project_id
  #:association_foreign_key

  #validates_associated :project, :milestone_category, :milestone_status
  #validates_presence_of :project_id, :milestone_status_id, :milestone_category_id, :description
#:measure_id
  validates_length_of :description, :minimum => 15
  
  validate do |milestone|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless milestone.project( true )
      milestone.errors.add :project_id, 'does not exist'
    end
    unless milestone.milestone_status( true )
      milestone.errors.add :milestone_status_id, 'does not exist'
    end
    unless milestone.milestone_category( true )
      milestone.errors.add :milestone_category_id, 'does not exist'
    end
    unless milestone.measure( true )
      milestone.errors.add :measure, 'does not exist'
    end
  end

  # Determine if an object instance is a Milestone
  def self.is_a_milestone?( object )
    #return object.class == self.class
    #return object.class.to_s == self.class.to_s
    return object.class.to_s == "Milestone"
  end
end
