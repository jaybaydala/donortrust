class Group < ActiveRecord::Base
  belongs_to :group_type
  has_many :investments
  has_many :memberships
  has_many :users, :through => :memberships
  #has_many :users, :through => :groupwall
  #has_many :users, :through => :group_admin_notes
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :sectors
  belongs_to :place

  validates_presence_of :name
  validates_inclusion_of :private, :in => [true, false]

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.group_type( true )
      me.errors.add :group_type_id, 'does not exist'
    end
    
    #need to validate the presence of other featured groups
    #  there cannot be more than 5 featured groups
    if me.featured == true
      if Group.count("featured = 1") >= 5
        me.errors.add "There are already 5 featured groups."
      end
    end
  end

  def project_count
    return projects.count
  end

  def user_count
    return users.count
  end

  def founder
    Membership.find_group_founder(self[:id])
  end
  
  def associated_sectors
    self.sectors.collect{ |sector| sector.id }
  end
  def associated_sectors=(sector_ids)
    all_sectors = Sector.find(:all)
    selected_sectors = []
    for sector_id in sector_ids
      sector = Sector.find(sector_id.to_i)
      self.sectors << sector if not self.sectors.include?(sector)
      selected_sectors << sector
    end
    missing_sectors = all_sectors - selected_sectors
    for sector in missing_sectors
      self.sectors.delete(sector) if self.sectors.include?(sector)
    end
  end
end
