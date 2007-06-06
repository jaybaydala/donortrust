class BusAdmin::PartnerTypesController < ApplicationController
  before_filter :login_required
  active_scaffold :partner_type do |config|  
    config.list.columns = [:name, :description] # reorder columns 
    config.create.columns = [:name, :description] # reorder columns 
    config.update.columns = [:name, :description] # reorder columns 
    config.show.columns = [:name, :description] # reorder columns 
  end

end
