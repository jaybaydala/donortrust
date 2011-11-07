class Iend::IendProfilesController < DtApplicationController
  before_filter :login_required

  def edit
    @iend_profile = current_user.iend_profile ? current_user.iend_profile : current_user.create_iend_profile
  end

  def update
    @iend_profile = current_user.iend_profile
    @iend_profile.update_attributes(params[:iend_profile])
  end
end