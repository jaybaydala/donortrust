class CountrySector < ActiveRecord::Base
  belongs_to :sector
  belongs_to :country
  #belongs_to :continent, :through => :country
  
  validates_presence_of :country_id, :sector_id, :content
  validates_uniqueness_of :sector_id, :scope => :country_id, :message => "and Country already taken"

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.sector( true )
      me.errors.add :sector_id, 'does not exist'
    end
    unless me.country( true )
      me.errors.add :country_id, 'does not exist'
    end
  end

  def label
    "#{country.name} #{sector.name}"
  end
end
