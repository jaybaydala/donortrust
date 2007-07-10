class BusAdmin::PartnerStatusesController < ApplicationController
  before_filter :login_required

  include ApplicationHelper
  
  active_scaffold :partner_statuses do |config|
    config.columns =[ :name, :description, :partners_count, :partners ]
    list.columns.exclude [ :description, :partners ]
    update.columns.exclude :partners_count, :partners
    create.columns.exclude :partners_count, :partners
#    show.columns.exclude
  end

  def destroy
    begin
      super.destroy
    rescue
      @error = "You cannot delete this status; it is being used by a Partner."
      flash[:error] = @error #for some reason this won't display      
      show_error_and_reset(@error)        
    end
  end
    
end
