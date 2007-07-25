class BusAdmin::PartnersController < ApplicationController
  before_filter :login_required
  active_scaffold :partner do |config|
#    config.theme = :blue

    config.columns[:partner_status].form_ui = :select
    config.columns[:partner_type].form_ui = :select
#    config.columns[:contacts].form_ui = :select
       
    config.create.columns.exclude :partner_versions
    config.list.columns.exclude :partner_versions
    config.update.columns.exclude :partner_versions
    
    config.list.columns = [:name, :description, :partner_status, :partner_type, :note] # reorder columns 
    config.create.columns = [:name, :description, :partner_status, :partner_type, :contacts, :note] # reorder columns 
    config.update.columns = [:name, :description, :partner_status, :partner_type, :contacts, :note] # reorder columns 
    config.show.columns = [:name, :description, :partner_status, :partner_type, :contacts, :note, :partner_versions] # reorder columns 
    
    config.nested.add_link("Projects", [:projects]) 

    #passing desired partner status in action link to filter list; 1 = Approved, 2 = Pending 
    config.action_links.add 'list', :label => 'Reports', :parameters =>{:controller=>'partners', :action => 'report_partners'},:page => true
    config.action_links.add 'list', :label => 'Pending', :parameters =>{:controller=>'partners', :status => '2'},:page => true
    config.action_links.add 'list', :label => 'Approved', :parameters =>{:controller=>'partners', :status => '1'},:page => true
#    config.action_links.add 'list', :label => 'All', redirect_to partners 
    
  end

  def conditions_for_collection  
    @displaystatus = params[:status]
    if(@displaystatus)  
      ['partner_status_id IN (?)', @displaystatus]  
    end
  end
  
  def report_partners    
    @all_partners = Partner.find(:all)
    @total = @all_partners.size
   render :partial => "bus_admin/partners/report_partners" , :layout => 'application'
  end
  
  def individual_report_partners 
    @partner = Partner.find(params[:partnerid])
   render :partial => "bus_admin/partners/individual_report_partners" , :layout => 'application'
  end
  
  def show_note   
   @note = Partner.find(params[:id]).note
   render :partial => "layouts/note"   
  end
end
