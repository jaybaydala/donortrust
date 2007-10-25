class PlaceFlickrImage < ActiveRecord::Base
  belongs_to :place

  validates_presence_of :place_id, :photo_id
 
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.place( true )
      me.errors.add :place_id, 'does not exist'
    end
  end

  
end


end
