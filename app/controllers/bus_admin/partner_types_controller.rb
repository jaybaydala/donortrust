class BusAdmin::PartnerTypesController < ApplicationController
  before_filter :login_required, :check_authorization
  
  include ApplicationHelper
  
  active_scaffold :partner_type do |config|   
    config.label = "Partner Categories"
    config.list.columns = [:name, :description] # reorder columns 
    config.create.columns = [:name, :description] # reorder columns 
    config.update.columns = [:name, :description] # reorder columns 
    config.show.columns = [:name, :description] # reorder columns 
  end

  def destroy
    begin
      super.destroy
    rescue
      @error = "You cannot delete this category; it is being used by a Partner."
      flash[:error] = @error #for some reason this won't display      
      show_message_and_reset(@error, "error")        
    end
  end
end
