class BusAdmin::PartnersController < ApplicationController
 before_filter :login_required, :check_authorization
  active_scaffold :partner do |config|
#    config.theme = :blue
    config.columns = [ :name, :description, :website, :partner_status, :partner_type, :contacts, :note,
                       :business_model, :funding_sources, :mission_statement, :philosophy_dev]
    config.columns[ :partner_status ].form_ui = :select
    config.columns[ :partner_status ].label = "Status"
    config.columns[ :partner_type ].form_ui = :select
    config.columns[ :partner_type ].label = "Category"
    config.columns[ :philosophy_dev ].label = "Philosophy Development"    
    config.columns[ :contacts ].form_ui = :select
    list.columns.exclude [ :description, :contacts,:business_model , :funding_sources, :mission_statement, :philosophy_dev ]
    config.nested.add_link("Projects", [:projects]) 

    #passing desired partner status in action link to filter list; 1 = Approved, 2 = Pending 
    config.action_links.add 'list', :label => 'Reports', :parameters =>{:controller=>'partners', :action => 'report_partners'},:page => true
    config.action_links.add 'list', :label => 'Pending', :parameters =>{:controller=>'partners', :status => '2'},:page => true
    config.action_links.add 'list', :label => 'Approved', :parameters =>{:controller=>'partners', :status => '1'},:page => true
    config.nested.add_link("Quick Fact", [:quick_fact_partners])
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

def get_local_actions(requested_action,permitted_action)
   if(requested_action == 'show_note')
      puts 'show note note !!!!!!!!!'
   end
      
   case(requested_action)
      when('show_note' || "conditions_for_collection" || "report_parnters" || "individual_report_partners")
        return permitted_action == 'edit' || permitted_action == 'show'
      else
        return false
      end  
 end

end
