class Milestone < ActiveRecord::Base
  has_many :tasks
  belongs_to :project
  belongs_to :milestone_status

  #attr_reader
  
  #:foreign_key => :project_id
  #:association_foreign_key

  #validates_associated :project, :milestone_status
  #validates_presence_of :project_id
  validates_presence_of :milestone_status_id
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description

  validate do |milestone|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
#    unless milestone.project( true )
#      milestone.errors.add :project_id, 'does not exist'
#    end
    unless milestone.milestone_status( true )
      milestone.errors.add :milestone_status_id, 'does not exist'
    end
  end

  # Determine if an object instance is a Milestone
  def self.is_a_milestone?( object )
    #return object.class == self.class
    #return object.class.to_s == self.class.to_s
    return object.class.to_s == "Milestone"
  end
end