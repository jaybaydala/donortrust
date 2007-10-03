class Group < ActiveRecord::Base
  belongs_to :group_type
  has_many :investments
  has_many :memberships
  has_many :users, :through => :memberships
  #has_many :users, :through => :groupwall
  #has_many :users, :through => :group_admin_notes
  has_and_belongs_to_many :projects

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
      groups = Group.find :all, :conditions => ["featured = 1"]
      if groups.length >= 5
        me.errors.add "There are already 5 featured groups. This group "
      end
    end
  end

  def project_count
    return projects.count
  end

  def user_count
    return users.count
  end
end
