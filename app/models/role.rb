class Role < ActiveRecord::Base
  has_many :users, :through => :administrations
  has_many :administrations
end
