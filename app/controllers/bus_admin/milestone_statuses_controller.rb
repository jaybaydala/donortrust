class BusAdmin::MilestoneStatusesController < ApplicationController
  before_filter :login_required, :check_authorization

  include ApplicationHelper

  active_scaffold :milestone_statuses do |config|
    config.columns =[ :name, :description, :milestones_count, :milestones ]
    #config.columns[ :name ].label = "Title"
    config.columns[ :milestones_count ].label = "Milestones"
    list.columns.exclude [ :milestones ]
    update.columns.exclude [ :milestones_count, :milestones ]
    create.columns.exclude [ :milestones_count, :milestones ]
    #show.columns.exclude [ ]
  end

#  def destroy
#    begin
#      super.destroy
#    rescue
#      @error = "You cannot delete this status; it is being used by a Milestone."
#      flash[:error] = @error #for some reason this won't display
#      show_message_and_reset(@error, "error")
#    end
#  end
end
