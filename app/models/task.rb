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

  attr_protected :milestone_id

  # save needs to create/save TaskHistory instance as well for audit trail
  def save
    save_success = false
    if( self.valid? )
      self.task_histories << TaskHistory.new( self )
      save_success = super
    end
    save_success
  end #save
  def save!
    save || raise( RecordNotSaved )
  end #save!

  def update_attributes( attributes )
    #compare self and attributes before save
    instance_modified = false
    attributes.each_pair { |attr, value| 
      if not( self.attributes[ attr ].eql? value )
        instance_modified = true 
      end
    }
    self.attributes = attributes
    if( instance_modified )
      save
    else #not instance_modified
      errors.add_to_base( "No change; #{self.class.to_s} instance update rejected" )
      self
    end #else not instance_modified 
  end #update_attributes
end