class PendingProject < ActiveRecord::Base
  belongs_to :project
  belongs_to :creator, :class_name => 'BusAccount', :foreign_key => 'created_by'
  belongs_to :rejector, :class_name => 'BusAccount', :foreign_key => 'rejected_by'
end
