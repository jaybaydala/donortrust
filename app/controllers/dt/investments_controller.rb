class Dt::InvestmentsController < ApplicationController
  before_filter :login_required
  helper 'dt/places'
  include FundCf
  
  def initialize
    @page_title = "Invest"
  end

  def new
    @action_js = "dt/giving"
    params[:investment] = {}
    params[:investment] = session[:investment_params] if session[:investment_params]
    params[:investment][:project_id] = params[:project_id] if params[:project_id]
    @investment = Investment.new( params[:investment] )
    @project = @investment.project if @investment.project_id? && @investment.project
    @investment.project_id = Project.cf_unallocated_project.id if (Project.cf_unallocated_project && !@investment.project_id?)
    respond_to do |format|
      format.html {
        redirect_to dt_project_path(@project) and return if @project && !@project.fundable?
      }
    end
  end
  
  def confirm
    session[:investment_params] = params[:investment] if params[:investment]
    @action_js = "dt/giving"
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    @investment.user_ip_addr = request.remote_ip
    @project = @investment.project if @investment.project_id? && @investment.project
   
    @cf_investment = build_fund_cf_investment(@investment)
    valid = cf_fund_investment_valid?(@investment, @cf_investment)
    @total_amount = @investment.amount + @cf_investment.amount if @cf_investment
    
    respond_to do |format|
      if valid
        format.html
      else 
        format.html { render :action => 'new' }
      end
    end
  end
  
  def create
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    @investment.user_ip_addr = request.remote_ip
    @investment_total = @investment.amount
    
    @cf_investment = build_fund_cf_investment(@investment)
    valid = cf_fund_investment_valid?(@investment, @cf_investment)

    @saved = false
    if valid
      Investment.transaction do 
        if @cf_investment
          @saved = @investment.save! && @cf_investment.save!
        else
          @saved = @investment.save!
        end
      end
    end
    
    respond_to do |format|
      if @saved
        session[:investment_params] = nil
        flash[:notice] = "The following project has received your investment: <strong>#{@investment.project.name}</strong>"
        if @cf_investment
          flash[:notice] = flash[:notice] + "<div>Thank you for your extra investment to support Christmas Future.</div>"
        end
        format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash.now[:error] = "There was a problem saving your Investment. Please review your information and try again."
        format.html { render :action => 'new' }
      end
    end
  end
  
  protected
  def ssl_required?
    true
  end
  
  private
  def user_validation(user)
    user.errors.add_on_empty %w( first_name last_name address city province postal_code country )
  end
end
