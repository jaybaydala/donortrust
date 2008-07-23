class Permission < ActiveRecord::Base
belongs_to :role
belongs_to :authorized_action

def to_label
  "#{self.role.title}-#{self.authorized_action.name}"
end

end
