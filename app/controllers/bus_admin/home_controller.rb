class BusAdmin::HomeController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  include BusAdmin::ProjectsHelper
  include BusAdmin::ProgramsHelper
  
  def index
    if current_user.cf_admin?
      cf_home
      render :action => 'cf_home'
    else
      partner_home
      render :action => 'partner_home'
    end
  end
  
  def cf_home
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
  
  def partner_home
    @user = current_user
    @partner = current_user.administrated_partners.first
    @projects = current_user.administrated_projects
  end
  
  def update_partner
    partner_home
    
    @partner.attributes = params[:partner]
    flash[:notice] = 'Profile updated successfully.' if @partner.valid? and @partner.save
    
    respond_to do |wants|
      wants.html {render :action => "partner_home"}
    end
  end
end
