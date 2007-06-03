#require 'rubygems'

class MilestoneHistory < ActiveRecord::Base
  belongs_to :milestone
  #belongs_to :contact
  #belongs_to :measure
  #belongs_to :project
  belongs_to :status

  validates_presence_of :reason
  validates_length_of :reason, :minimum => 10
  
  def to_label
    "#{created_at}"
  end

  # do not bother validating fields that also exist in Milestone
  # just need to used milestone.valid? after copy to milestone fields
  
  # create a new MilestoneHistory (instance) populated with information from
  # a Milestone instance
  def self.new_audit( milestone )
    raise ArgumentError, "need a Milestone, not a '#{milestone.class.to_s}'" if not Milestone.is_a_milestone?( milestone )
    mh                = MilestoneHistory.new
    mh.milestone_id   = milestone.id
    mh.category       = milestone.category
    mh.description    = milestone.description
    mh.start          = milestone.start
    mh.end            = milestone.end
    mh.status_id      = milestone.status_id
    #mh.project_id     = milestone.project_id
    #mh.contact_id     = milestone.contact_id
    #mh.measure_id     = milestone.measure_id
    return mh
  end
  
  # save the new history record, and update the Milestone to match
  def save_audit( milestone )
    raise ArgumentError, "need a Milestone" if not Milestone.is_a_milestone?( milestone )
    raise ArgumentError, "milestone to history id mismatch" if not milestone.id == self.milestone_id
    raise RangeError, "no change to milestone" if self.matches( milestone )
    raise IndexError, "milestone project changed" if not self.project_id = milestone.project_id
    save_result           = false
    milestone.category    = self.category
    milestone.description = self.description
    milestone.start       = self.start
    milestone.end         = self.end
    milestone.status_id   = self.status_id
    #milestone.measure_id  = self.measure_id
    #milestone.contact_id  = self.contact_id
    #do NOT change project_id
    # if milestone.valid?
    if( milestone.update )
      self.milestone_id   = milestone.id
      save_result         = self.save
    end
    return save_result
  end
  
  def matches( milestone )
    milestone_matches = true
    milestone_matches = false if milestone.id           != self.milestone_id
    milestone_matches = false if milestone.category     != self.category
    milestone_matches = false if milestone.description  != self.description
    milestone_matches = false if milestone.start        != self.start
    milestone_matches = false if milestone.end          != self.end
    milestone_matches = false if milestone.status_id    != self.status_id
    #milestone_matches = false if milestone.contact_id   != self.contact_id
    #milestone_matches = false if milestone.project_id   != self.project_id
    #milestone_matches = false if milestone.measure_id   != self.measure_id
    return milestone_matches
  end
end
