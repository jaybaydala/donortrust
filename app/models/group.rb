class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  belongs_to :group_type

  validates_presence_of     :name
  validates_uniqueness_of   :name
  validates_presence_of     :group_type_id
end
