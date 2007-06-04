class MilestoneCategory < ActiveRecord::Base
  has_many :milestones
  has_many :milestone_histories

  validates_presence_of :category
  validates_uniqueness_of :category
  validates_presence_of :description

  def to_label
    "#{category}"
  end
end
