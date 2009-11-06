class StatisticWidget < ActiveRecord::Base
  validates_presence_of :title, :progress, :goal, :goal_name
  validates_numericality_of :goal
  
  def progress_as_percentage(progress)
    @progress_as_percentage ||= (progress.to_f / self.goal.to_f * 100)
    @progress_as_percentage = @progress_as_percentage.floor if @progress_as_percentage > 99
    @progress_as_percentage = @progress_as_percentage.ceil if @progress_as_percentage < 1
    @progress_as_percentage
  end
end