class Milestone < ActiveRecord::Base
  has_many :milestone_histories
  #belongs_to :contact
  #belongs_to :measure
  #belongs_to :project
  belongs_to :status

  validates_presence_of :category, :description, :start, :status_id
  validates_length_of :category, :minimum => 10
  validates_length_of :description, :minimum => 15
  # end (when exists) > start

  # create a new MilestoneHistory (instance) populated with information from
  # the Milestone instance when saving a new Milestone
  def save_with_audit
    save_result         = false
    if( self.save )
      mh                = MilestoneHistory.new
      mh.milestone_id   = self.id
      mh.category       = self.category
      mh.description    = self.description
      mh.start          = self.start
      mh.end            = self.end
      mh.status_id      = self.status_id
      #mh.project_id     = self.project_id
      #mh.contact_id     = self.contact_id
      #mh.measure_id     = self.measure_id
      mh.reason         = "Initial Milestone creation"
      save_result       = mh.save
    end
    return save_result
  end
  
  # Determine if an object instance is a Milestone
  def self.is_a_milestone?( object )
    #return object.class == self.class
    #return object.class.to_s == self.class.to_s
    return object.class.to_s == "Milestone"
  end
end
