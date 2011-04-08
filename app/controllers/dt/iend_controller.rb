class Dt::IendController < DtApplicationController
  def index
  end
  
  def show
    @user = User.find(params[:id])
  end
end