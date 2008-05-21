class Dt::InvestmentsController < DtApplicationController
  helper 'dt/places'
  include CartHelper
  
  def new
    @investment = Investment.new( params[:investment] )
    @investment.project_id = params[:project_id] if params[:project_id]
    # load the cf_unallocated_project if no other project is loaded
    @investment.project = Project.cf_unallocated_project if (Project.cf_unallocated_project && !@investment.project)
    @project = @investment.project if @investment.project
    respond_to do |format|
      format.html {
        if @project && !@project.fundable?
          flash.now[:error] = "The &quot;#{@project.name}&quot; is fully funded. Please choose another project."
          redirect_to dt_project_path(@project) and return
        end
      }
    end
  end
  
  def create
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user if logged_in?
    @investment.user_ip_addr = request.remote_ip
    
    @valid = @investment.valid?
    
    respond_to do |format|
      if @valid
        session[:investment_params] = nil
        @cart = find_cart
        @cart.add_item(@investment)
        flash[:notice] = "Your Investment has been added to your cart."
        format.html { redirect_to dt_cart_path }
      else
        flash.now[:error] = "There was a problem adding the Investment to your cart. Please review your information and try again."
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
