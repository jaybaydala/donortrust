class AuthorizedAction < ActiveRecord::Base

belongs_to :authorized_controller
has_many :roles, :through => :permissions
has_many :permissions

def to_label
  "#{self.authorized_controller.name}/#{read_attribute(:name)}"
end


end