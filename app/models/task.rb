require 'acts_as_paranoid_versioned'
class Task < ActiveRecord::Base
  acts_as_simile_timeline_event(
    :fields =>
    {
      :start       => :startDate,
      :end         => :endDate,
      :title       => :name,
      :description => :description
    }
  )
  acts_as_paranoid_versioned

  belongs_to    :milestone

  validates_presence_of :name, :description#, :milestone_id
  validates_uniqueness_of :name, :scope => :milestone_id
  
  def startDate
  "#{self.start_date}"
  end
  def endDate
  "#{self.end_date}"
  end
  validate do |task|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless task.milestone( true )
      task.errors.add :milestone_id, 'does not exist'
    end
  end

  attr_protected :milestone_id
end