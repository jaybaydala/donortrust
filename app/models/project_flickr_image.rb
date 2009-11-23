class ProjectFlickrImage < ActiveRecord::Base
  belongs_to :project, :touch => true
  validates_presence_of :project_id, :photo_id
 

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
   
    unless me.project( true )
      me.errors.add :project_id, 'does not exist'
    end
  end

 
end
