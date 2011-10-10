class Iend::IendProfilesController < DtApplicationController
  before_filter :login_required

  def show
  end

  def edit
    @iend_profile = current_user.iend_profile ? current_user.iend_profile : current_user.create_iend_profile
  end

  def update
  end
end