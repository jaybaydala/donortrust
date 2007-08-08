class Task < ActiveRecord::Base
  acts_as_versioned

  has_many      :task_versions
  belongs_to    :milestone

  validates_presence_of :name, :description#, :milestone_id
  validates_uniqueness_of :name, :scope => :milestone_id
  
  validate do |task|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless task.milestone( true )
      task.errors.add :milestone_id, 'does not exist'
    end
  end

  attr_protected :milestone_id

  def version_count
    return task_versions.count
  end
end