class Dt::StaffController < DtApplicationController
  # before_filter :login_required
  
  def show
    @users = User.find(:all, :conditions =>{:staff=>1})
    respond_to do |format|
      format.html { }# index.html.erb
    end
  end
end