class Dt::InvestmentsController < DtApplicationController
  before_filter :login_required
  helper 'dt/places'
  
  def ssl_required?
    true
  end
  
  def new
    @investment = Investment.new( :project_id => params[:project_id] )
    @projects = Project.find(:all) if !params[:project_id]
    @project = Project.find(params[:project_id]) if params[:project_id]
     @cfSupportProject = Project.find(:first, :conditions => ['name = ?', "ChristmasFuture Operational Overhead" ])
    #    @tax_receipt = TaxReceipt.new do |r|
    #      r[:first_name] = current_user[:first_name]
    #      r[:last_name] = current_user[:last_name]
    #      r[:address] = current_user[:address]
    #      r[:city] = current_user[:city]
    #      r[:province] = current_user[:province]
    #      r[:postal_code] = current_user[:postal_code]
    #      r[:country] = current_user[:country]
    #    end
  end
  
  def confirm
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    @fundCf = 0
    @fundCf = params[:fund_cf]
    @investment_total = @investment.amount
   
    #    @tax_receipt = TaxReceipt.new( params[:tax_receipt] )
    #    @tax_receipt.investment = @investment
    #    @tax_receipt.user = current_user
    @projects = Project.find(:all) if !params[:project_id]
   
    @cfSupportProject = Project.find(:first, :conditions => ['name = ?', "ChristmasFuture Operational Overhead" ])
    @user = current_user
     if @fundCf
          @cf_amount = @investment_total * 0.05  
          @CFinvestment = Investment.new(:amount => @cf_amount,  :project_id => @cfSupportProject.id, :user_id => current_user.id  )
          @CFinvestment.user = current_user
          @investment.amount = @investment.amount + @cf_amount
           
     end

    respond_to do |format|
      if @investment.valid?   #&& @tax_receipt.valid? #&& user.save
        @investment.amount = @investment_total
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
    @fundCf = 0
    @fundCf = params[:fund_cf]
    @cfSupportProject = Project.find(:first, :conditions => ['name = "ChristmasFuture Operational Overhead"' ])
    has_cf_investment = false
    if @fundCf
      cf_amount = @investment_total * 0.05  
      @CFinvestment = Investment.new(:amount => cf_amount,  :project_id => @cfSupportProject.id, :user_id => current_user.id  )
      @CFinvestment.user = current_user
 
      @CFinvestment.user_ip_addr = request.remote_ip
      
    end
    #    @tax_receipt = TaxReceipt.new( params[:tax_receipt] )
    #    @tax_receipt.investment = @investment
    #    @tax_receipt.user = current_user
    @saved = false
    @investment.user_ip_addr = request.remote_ip
    
    if @investment.valid? 
      Investment.transaction do 
        if @fundCf
          @saved =  @investment.save! && @CFinvestment.save!
        else
          @saved =  @investment.save!
        end
      end
    end
    
    respond_to do |format|
      if @saved
        #        @tax_receipt.send_tax_receipt
        flash[:notice] = "The following project has received your investment: <strong>#{@investment.project.name}</strong>"
        if has_cf_investment
          flash[:notice] = flash[:notice] + "<br>Thank you for your extra donation to support Christmas Future."
        end
        format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash.now[:error] = "There was a problem saving your Investment. Please review your information and try again."
        format.html { render :action => 'new' }
      end
    end
  end
  
  private
  def user_validation(user)
    user.errors.add_on_empty %w( first_name last_name address city province postal_code country )
  end
end
