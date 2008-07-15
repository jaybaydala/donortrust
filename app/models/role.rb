class Role < ActiveRecord::Base
  has_many :users, :through => :administrations
  has_many :authorized_actions, :through => :permissions
  has_many :administrations
  has_many :permissions
end
