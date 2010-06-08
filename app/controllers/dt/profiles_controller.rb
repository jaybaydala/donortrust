class Dt::ProfilesController < DtApplicationController

  def show
    if params[:id] =~ /^\d*$/
      @user = User.find(params[:id]) || current_user
      @user.profile if @user
    else
      @user = Profile.find_by_short_name(params[:id]).user
    end
  end

end