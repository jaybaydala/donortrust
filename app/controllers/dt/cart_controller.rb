require 'order_helper'
class Dt::CartController < DtApplicationController
  include OrderHelper
  def show
    @cart = find_cart
  end

  def destroy
    @cart = find_cart
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
