class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_uniqueness_of :group_id, :scope => :user_id, :message => "already taken"

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    me.errors.add :user_id, 'does not exist' unless me.user( true )
    me.errors.add :group_id, 'does not exist' unless me.group( true )
  end
  
  def before_save
    self[:membership_type] = Membership.member unless [Membership.founder, Membership.admin, Membership.member].include?(self[:membership_type])
    if ![Membership.founder, Membership.admin, Membership.member].include?(self[:membership_type])
      pp "hithere"
    end
  end
  
  def founder?; membership_type == Membership.founder ? true : false; end
  def owner?;   founder?; end
  def admin?;   membership_type >= Membership.admin ? true : false; end
  def member?;  membership_type >= Membership.member ? true : false; end

  class << self
    def founder; 3; end
    def owner; founder; end
    def admin; 2; end
    def member; 1; end
    
    def find_group_founder(group_id)
      member = find_by_membership_type(Membership.founder, :conditions => {:group_id => group_id})
      founder = member.user if member && member.user_id? && !member.user.nil?
    end
  end
end
