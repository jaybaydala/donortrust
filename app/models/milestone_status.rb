class MilestoneStatus < ActiveRecord::Base
  has_many :milestones

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description
end
