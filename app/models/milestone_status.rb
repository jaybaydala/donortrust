class MilestoneStatus < ActiveRecord::Base
  has_many :milestones
  has_many :milestone_histories

  validates_presence_of :status
  validates_uniqueness_of :status
  validates_presence_of :description
end
