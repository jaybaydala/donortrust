require 'acts_as_paranoid_versioned'
class Task < ActiveRecord::Base
  acts_as_simile_timeline_event(
    :fields =>
    {
      :start       => :startDate,
      :end         => :endDate,
      :title       => :name
    }
  )
  acts_as_paranoid_versioned

  belongs_to    :milestone

  validates_presence_of :name, :description#, :milestone_id
  validates_uniqueness_of :name, :scope => :milestone_id
  
  def startDate
    "#{self.target_start_date}"
  end
  def endDate
    "#{self.target_end_date}"
  end
  validate do |task|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless task.milestone( true )
      task.errors.add :milestone_id, 'does not exist'
    end
  end

  def validate_on_create
    check_deleted
  end
  
  def validate_on_update
    check_deleted
    #check_deleted( :condtions => [ "name = ?", name ])
  end
  
# Perhaps this can be refactored.  Is there a good place to put a generic check_deleted method?
#  def get_model
#    return Task
#  end

  protected
  def check_deleted
    check_result = true
    existing = Task.find_with_deleted( :all, :conditions => [ "name = ? and milestone_id = ?", name, milestone_id ])
    #Is it practical to make this generic, and have it figure out the needed constraint conditions?
    #existing = self.get_model.find_with_deleted( :all, :conditions => [ "name = ? and milestone_id = ?", name, milestone_id ])
    if existing.size > 0 then
      # if existing.size > 1 then exception duplicates already exists
      if not existing[ 0 ].deleted_at.nil? then
        check_result = false 
        self.errors.add :name, 'already exists but is inactive'
      end
    end
    return check_result
  end
  
  attr_protected :milestone_id
end