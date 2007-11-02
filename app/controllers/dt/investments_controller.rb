class Dt::InvestmentsController < DtApplicationController
  before_filter :login_required
  helper 'dt/places'
  
  def new
    @investment = Investment.new( :project_id => params[:project_id] )
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
  
  def confirm
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    @project = @investment.project if @investment.project_id? && @investment.project
   
    if params[:fund_cf] && cf_admin_project = Project.cf_admin_project
      @cf_amount = @investment.amount * 0.05
      @cf_investment = Investment.new( @investment.attributes.merge(:amount => @cf_amount,  :project_id => cf_admin_project.id ) )
      @total_investment_amount = @investment.amount + @cf_investment.amount
    end

    if @cf_investment
      @investment.amount += @cf_investment.amount # temporarily add the entire amount to the original investment - this will test the account balance
      valid = @investment.valid? && @cf_investment.valid?
      @investment.amount -= @cf_investment.amount # subtract the 5% overhead again
    else 
      valid = @investment.valid?
    end
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
    @investment_total = @investment.amount
    @investment.user_ip_addr = request.remote_ip
    
    if params[:fund_cf] && cf_admin_project = Project.cf_admin_project
      @cf_amount = @investment.amount * 0.05
      @cf_investment = Investment.new( @investment.attributes.merge(:amount => @cf_amount,  :project_id => cf_admin_project.id ) )
      @cf_investment.user_ip_addr = request.remote_ip
      @total_investment_amount = @investment.amount + @cf_investment.amount
    end
    
    if @cf_investment
      @investment.amount += @cf_investment.amount # temporarily add the entire amount to the original investment - this will test the account balance
      valid = @investment.valid? && @cf_investment.valid?
      @investment.amount -= @cf_investment.amount # subtract the 5% overhead again
    else 
      valid = @investment.valid?
    end

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
