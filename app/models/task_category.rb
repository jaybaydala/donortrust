class TaskCategory < ActiveRecord::Base
  has_many :tasks
  has_many :task_histories

  validates_presence_of :category
  validates_uniqueness_of :category
  validates_presence_of :description
end
