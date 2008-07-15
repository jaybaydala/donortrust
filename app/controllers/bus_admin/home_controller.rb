class BusAdmin::HomeController < ApplicationController
  layout 'admin'
  before_filter :check_authorization
  #access_control :DEFAULT => 'cf_admin' 


  include BusAdmin::ProjectsHelper
  include BusAdmin::ProgramsHelper
  
  def index
    @all_partners = Partner.find(:all)
    @total_partners = @all_partners.size 
    @all_projects = Project.find(:all)#get_projects 
    @total_projects = @all_projects.size
    @all_programs = Program.find(:all)
    @total_programs = @all_programs.size 
    @total_money_raised = Project.total_money_raised #total_money_raised
    @total_project_costs = Project.total_costs
    @total_money_spent = Project.total_money_spent #total_money_spent
    @total_percent_raised = Project.total_percent_raised
  end
  
end
