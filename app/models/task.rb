class Task < ActiveRecord::Base
  has_many :task_histories
  belongs_to :milestone
  belongs_to :task_category
  belongs_to :task_status

  validates_presence_of :title, :description
    #, :milestone_id, :task_category_id, :task_status_id
  validates_uniqueness_of :title
  validates_length_of :description, :minimum => 15
  
  validate do |task|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless task.milestone( true )
      task.errors.add :milestone_id, 'does not exist'
    end
    unless task.task_status( true )
      task.errors.add :task_status_id, 'does not exist'
    end
    unless task.task_category( true )
      task.errors.add :task_category_id, 'does not exist'
    end
  end

  # Determine if an object instance is a Milestone
  def self.is_a_task?( object )
    #return object.class == self.class
    #return object.class.to_s == self.class.to_s
    return object.class.to_s == "Task"
  end
end