class MyWishlist < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_uniqueness_of :project_id, :scope => :user_id, :message => "already taken"

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    me.errors.add :user_id, 'does not exist' unless me.user( true )
    me.errors.add :project_id, 'does not exist' unless me.project( true )
  end
end
