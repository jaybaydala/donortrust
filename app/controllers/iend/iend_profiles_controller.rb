class Iend::IendProfilesController < DtApplicationController
  before_filter :login_required

  def edit
    @iend_profile = current_user.iend_profile ? current_user.iend_profile : current_user.create_iend_profile
  end

  def update
    @iend_profile = current_user.iend_profile
    if @iend_profile.update_attributes(params[:iend_profile])
      flash[:notice] = "We've updated your public iEnd profile"
      redirect_to edit_iend_profile_path
    else
      render :action => "edit"
    end
  end
end