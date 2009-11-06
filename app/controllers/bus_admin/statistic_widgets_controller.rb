class BusAdmin::StatisticWidgetsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
   
  active_scaffold do |config|
    config.columns = [ :title, :progress, :goal, :goal_modifier, :goal_name, :position, :active ]
    config.list.columns = [:title, :progress, :goal, :goal_modifier, :goal_name, :position, :active]
  end
end
