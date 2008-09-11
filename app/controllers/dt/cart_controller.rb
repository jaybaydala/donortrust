require 'order_helper'
class Dt::CartController < DtApplicationController
  include OrderHelper
  before_filter :find_cart
  def show
    if session[:gift_card_amount]
      gift_card_balance = session[:gift_card_amount] - @cart.total
      if gift_card_balance >= 0
        flash.now[:notice] = "You've invested #{number_to_currency(@cart.total)} and have #{number_to_currency(gift_card_balance)} remaining on your gift card"
      else
        flash.now[:notice] = "You've invested #{number_to_currency(@cart.total)} and have #{number_to_currency(gift_card_balance.abs)} remaining on your gift card"
      end
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
