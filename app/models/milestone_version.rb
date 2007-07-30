class MilestoneVersion < ActiveRecord::Base
  belongs_to :project
  belongs_to :milestone
  belongs_to :milestone_status
end