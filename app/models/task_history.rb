class TaskHistory < ActiveRecord::Base
  belongs_to :task
  belongs_to :milestone
  belongs_to :task_category
  belongs_to :task_status

  # want to 'inherit' the validations of Task, without duplicating here
  # 'real inherit??
  # disallow edit

  validate do |history|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless history.task( true )
      history.errors.add :task_id, 'does not exist'
    end
  end
  
  private
  #prevent 'direct' call to standard / inherited save
  #def save
  #  parent.save
  #end #save
  # Prevent edit / update of history record.  Supposed to be audit trail of changes.
  def update
    return false
  end
end