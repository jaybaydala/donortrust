class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  validates_presence_of :user_id,  :group_id, :to_email
  validates_format_of   :to_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address"
  
  validate do |i|
    i.errors.add :user_id, 'does not exist' unless i.user(true)
    i.errors.add :group_id, 'does not exist' unless i.group(true)
    i.errors.add :group_id, 'is not accessible to non-members' unless i.group && i.group.member(i.user)
    if i.group && i.group.private?
      i.errors.add :group_id, 'is not accessible to non-admins' unless i.group.member(i.user) && i.group.member(i.user).admin?
    end
  end
end
