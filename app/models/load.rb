class Load < ActiveRecord::Base
  validates_presence_of :name, :email#, :sent, :invitation
  validates_uniqueness_of :email
end
