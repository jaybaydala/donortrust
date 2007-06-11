class BusAdmin::PartnersController < ApplicationController
  before_filter :login_required
  active_scaffold :partner do |config|
    config.columns[:partner_status].ui_type = :select
    config.columns[:partner_type].ui_type = :select

#    config.columns['partner_histories'].set_link('nested', :parameters => {
#      :associations => :partner_histories, 
#      :controller => 'partner_histories', 
#      :action => 'list'})
    
    config.create.columns.exclude :partner_histories
    config.list.columns.exclude :partner_histories
    config.update.columns.exclude :partner_histories
    
    config.list.columns = [:name, :description, :partner_status, :partner_type, :contacts] # reorder columns 
    config.create.columns = [:name, :description, :partner_status, :partner_type, :contacts] # reorder columns 
    config.update.columns = [:name, :description, :partner_status, :partner_type, :contacts] # reorder columns 
    config.show.columns = [:name, :description, :partner_status, :partner_type, :contacts, :partner_histories] # reorder columns 
    #config.columns['partner_histories'].link.action = :partner_histories_controller
    
    #passing desired partner status in action link to filter list; 1 = Approved, 2 = Pending 
    config.action_links.add 'list', :label => 'Pending', :parameters =>{:controller=>'partners', :status => '2'},:page => true
    config.action_links.add 'list', :label => 'Approved', :parameters =>{:controller=>'partners', :status => '1'},:page => true

    # doesn't work in release 1.0 with nested RESTful URLs - may be fixed in later version
    # if you have the entity un-nested for a work around - note that it does use the un-nested path for nesting
    config.nested.add_link("Show history", [:partner_histories])    
  end

  def conditions_for_collection  
    @displaystatus = params[:status]
    if(@displaystatus)  
      ['partner_status_id IN (?)', [@displaystatus]]   
    end
  end
   
end
