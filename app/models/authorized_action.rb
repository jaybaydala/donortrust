class AuthorizedAction < ActiveRecord::Base

belongs_to :authorized_controller
has_many :roles, :through => :permissions
has_many :permissions

end
