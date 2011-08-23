class Iend::OrdersController < DtApplicationController
  before_filter :login_required

  def index
    @orders = current_user.orders.complete.paginate(:page => params[:tx_page], :order => "updated_at DESC")
  end
end