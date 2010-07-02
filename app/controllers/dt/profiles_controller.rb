class Dt::ProfilesController < DtApplicationController

  before_filter :find_profile

  def show
    
  end
  
  def increase_gifts
    respond_to do |format|
      format.js do
        @profile.increase_gifts if @profile.user == current_user
        render :text => @profile.non_uend_gifts
      end
    end
  end
  
  def decrease_gifts
    respond_to do |format|
      format.js do
        @profile.decrease_gifts if @user == current_user
        render :text => @profile.non_uend_gifts
      end
    end
  end
  
  def request_gift
    respond_to do |format|
      format.js do
        if @user != current_user and current_user != :false
          DonortrustMailer.deliver_gift_request(@profile, current_user)
          render :update do |page|
            page.alert "An e-mail has been sent letting them know what you want!"
          end
        end
      end
    end
  end
  
  protected
  def find_profile
    if params[:id] =~ /^\d*$/
      @user = User.find(params[:id])
      @profile = @user.profile if @user
    else
      @profile = Profile.find_by_short_name(params[:id])
      @user = @profile.user if @profile
    end
    redirect_to "/dt/" and return unless @profile
  end

end