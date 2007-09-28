class PlaceSector < ActiveRecord::Base
  
  belongs_to :sector
  belongs_to :place
  
  
  validates_presence_of :place_id, :sector_id, :content
  validates_uniqueness_of :sector_id, :scope => :place_id, :message => "and Country already taken"

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.sector( true )
      me.errors.add :sector_id, 'does not exist'
    end
    unless me.country( true )
      me.errors.add :place_id, 'does not exist'
    end
  end

  def label
    "#{place.name} #{sector.name}"
  end
end

