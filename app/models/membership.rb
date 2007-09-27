class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_uniqueness_of :group_id, :scope => :user_id, :message => "already taken"

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.user( true )
      me.errors.add :user_id, 'does not exist'
    end
    unless me.group( true )
      me.errors.add :group_id, 'does not exist'
    end
  end
  
  def owner?
    if membership_type == 3
      true 
    else
      false
    end
  end

  def admin?
    if membership_type >= 2
      true 
    else
      false
    end
  end

  def member?
    if membership_type >= 1
      true 
    else
      false
    end
  end
end
