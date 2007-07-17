class Task < ActiveRecord::Base
  belongs_to :milestone

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

end