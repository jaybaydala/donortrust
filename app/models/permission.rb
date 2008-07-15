class Permission < ActiveRecord::Base
belongs_to :role
belongs_to :authorized_action

end
