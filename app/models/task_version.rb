class TaskVersion < ActiveRecord::Base
  belongs_to :task
  belongs_to :milestone
end