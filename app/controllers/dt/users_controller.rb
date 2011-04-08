class Dt::UsersController < DtApplicationController
  before_filter :login_required
  helper "dt/places"
  helper "dt/forms"

  def edit
    @user = current_user
  end
  def edit_password
    @authentications = current_user.authentications
    @user = current_user
  end
end