require 'cart_helper'
class Dt::CheckoutsController < DtApplicationController
  helper "dt/places"
  include CartHelper
  
  def index
    redirect_to :action => "new"
  end
  
  def new 
    @cart = find_cart
    @order = find_order
    respond_to do |format|
      format.html {
        render :action => (params[:step] ? params[:step] : "new")
      }
    end
  end

  def create
    @cart = Cart.new( (params[:confirm] ? true : false) )
    @order = find_order
    respond_to do |format|
      if params[:step] == "complete"
        # check for account creation
        # ...
        # process credit card
        # @order.save
        flash[:notice] = "Your checkout is complete!"
      end
      format.html {
        if params[:step] == "payment"
          render :action => "payment"
        elsif params[:step] == "confirm"
          render :action => "confirm"
        elsif params[:step] == "complete"
          redirect_to dt_checkout_path
        else
          render :action => "new"
        end
      }
    end
  end
  
  def show
    @cart = Cart.new #this will need to get removed
    @order = find_order
    redirect_to :action => 'new' unless @order.complete?
  end

  protected
  def ssl_required?
    true
  end
end
