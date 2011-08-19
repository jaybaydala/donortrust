class Iend::UsersController < DtApplicationController
  def show
    @user = User.find(params[:id])
  end
end