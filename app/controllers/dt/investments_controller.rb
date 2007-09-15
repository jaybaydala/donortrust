class Dt::InvestmentsController < DtApplicationController
  before_filter :login_required

  def new
    @user = current_user
    @investment = Investment.new( :project_id => params[:project_id] )
    @projects = Project.find(:all) if !params[:project_id]
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
  
  def confirm
    @user = current_user
    user_validation(@user)
    @user.attributes = params[:user] if params[:user]
    @investment = Investment.new( params[:investment] )
    @investment.user = @user
    respond_to do |format|
      if @investment.valid? && @user.save
        format.html
      else
        format.html { render :action => 'new' }
      end
    end
  end
  
  def create
    @investment = Investment.new( params[:investment] )
    @investment.user = current_user
    respond_to do |format|
      if @investment.save
        flash[:notice] = "The following project has received your investment: <strong>#{@investment.project.name}</strong>"
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
