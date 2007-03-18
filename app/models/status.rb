class Status < ActiveRecord::Base
  has_many :milestone_histories
  has_many :milestones
end
