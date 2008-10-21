require 'order_helper'
class Dt::CartController < DtApplicationController
  include OrderHelper
  before_filter :find_cart
  def show
    @cart_items = @cart.items.paginate(:page => params[:cart_page], :per_page => 10)
    respond_to do |format|
      format.html {
        unless params[:sidebar].nil?
          render :action => "sidebar" and return
        end
        render :action => "show"
      }
    end
  end
  
  def destroy
    if params[:id]
      @cart.remove_item(params[:id]) if params[:id] && @cart.items[params[:id].to_i]
      flash[:notice] = "Your item has been removed from your cart."
    else
      @cart.empty!
      flash[:notice] = "Your cart has been emptied."
    end
    redirect_to dt_cart_path
  end
end
