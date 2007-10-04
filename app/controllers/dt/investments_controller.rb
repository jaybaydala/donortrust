class Dt::InvestmentsController < DtApplicationController
  before_filter :login_required

  def new
    @investment = Investment.new( :project_id => params[:project_id] )
    @projects = Project.find(:all) if !params[:project_id]
    @project = Project.find(params[:project_id]) if params[:project_id]
    @tax_receipt = TaxReceipt.new do |r|
      r[:first_name] = current_user[:first_name]
      r[:last_name] = current_user[:last_name]
      r[:address] = current_user[:address]
      r[:city] = current_user[:city]
      r[:province] = current_user[:province]
      r[:postal_code] = current_user[:postal_code]
      r[:country] = current_user[:country]
    end
  end
  
  def confirm
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    @tax_receipt = TaxReceipt.new( params[:tax_receipt] )def tax_receipt] ) (args)
      
    end
     
    @tax_receipt.investment = @investment
    @tax_receipt.user = current_user
    @projects = Project.find(:all) if !params[:project_id]
    respond_to do |format|
      if @investment.valid? && @tax_receipt.valid? #&& user.save
        format.html
      else
        format.html { render :action => 'new' }
      end
    end
  end
  
  def create
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    @tax_receipt = TaxReceipt.new( params[:tax_receipt] )
    @tax_receipt.investment = @investment
    @tax_receipt.user = current_user
    respond_to do |format|
      Investment.transaction do
        if @investment.save && @tax_receipt.save
          flash[:notice] = "The following project has received your investment: <strong>#{@investment.project.name}</strong>"
          format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
        else
          flash.now[:error] = "There was a problem saving your Investment. Please review your information and try again."
          format.html { render :action => 'new' }
        end
      end
    end
  end

  private
  def user_validation(user)
    user.errors.add_on_empty %w( first_name last_name address city province postal_code country )
  end
end
