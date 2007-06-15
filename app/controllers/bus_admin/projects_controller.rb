class BusAdmin::ProjectsController < ApplicationController
  before_filter :login_required  
  
  active_scaffold :project do |config|
  
    config.list.columns = [:name, :description,   :program, :start_date, :end_date, :dollars_raised, :dollars_spent]                          
    config.show.columns = [:name, :description,  :program,  :expected_completion_date, 
                          :start_date, :end_date, :dollars_raised, :dollars_spent, :total_cost, :contact_id, :project_histories]
    config.update.columns = [:name, :description, :program, :expected_completion_date, 
                          :start_date, :end_date, :dollars_raised, :dollars_spent, :total_cost, :contact_id]
    config.create.columns = [:name, :description,  :program, :expected_completion_date, 
                          :start_date, :end_date, :dollars_raised, :dollars_spent, :total_cost]
    config.nested.add_link("History", [:project_histories])  
    
    #config.action_links.add 'report', :label => 'Report'
    config.action_links.add 'list', :label => 'Reports', :parameters =>{:controller=>'projects', :action => 'report'},:page => true
    config.create.columns.exclude :project_histories
    config.list.columns.exclude :project_histories
    config.update.columns.exclude :project_histories
#    config.columns[:program].form_ui = :select
  end
  
  def report    
   @id = params[:id]
   render :partial => "bus_admin/projects/report" , :layout => 'application' , :myparams => '5'
  end
  
  def individual_report    
   @myparam = params[:myparam]
   render :partial => "bus_admin/projects/individualreport" , :layout => 'application' , :myparams => @myparam
  end
end
