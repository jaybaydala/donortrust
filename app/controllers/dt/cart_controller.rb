require 'order_helper'
class Dt::CartController < DtApplicationController
  include OrderHelper
  before_filter :no_donations
  before_filter :find_cart
  def show
    @cart_items = @cart.items.all(:conditions => ['donation != ?', true]).paginate(:page => params[:cart_page], :per_page => 10)
    respond_to do |format|
      format.html {
        if @cart.subscription? && !params[:skip_cart].blank?
          redirect_to new_dt_checkout_path and return
        end
        unless params[:sidebar].nil?
          @cart_items = @cart.items.paginate(:page => params[:cart_page], :per_page => 5)
          render :action => "sidebar", :layout => false and return
        end
        render :action => "show", :layout => false and return if request.xhr?
        render :action => "show"
      }
    end
  end

  def destroy
    if params[:id]
      @cart.remove_item(params[:id]) if params[:id]
      flash[:notice] = "Your item has been removed from your cart."
    else
      @cart.empty!
      flash[:notice] = "Your cart has been emptied."
    end
    redirect_to dt_cart_path
  end

  private
    def no_donations
      flash[:notice] = "We are very sorry, but we are no longer taking donations."
      redirect_to root_path
      false
    end
end
