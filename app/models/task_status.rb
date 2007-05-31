class TaskStatus < ActiveRecord::Base
  has_many :tasks
  has_many :task_histories

  validates_presence_of :status
  validates_uniqueness_of :status
  validates_presence_of :description

  def to_label
    "#{status}"
  end
end
