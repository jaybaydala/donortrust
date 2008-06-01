class Dt::CheckoutsController < ApplicationController
  helper "dt/places"
  
  def index
    redirect_to :action => "new"
  end
  
  def new 
    @cart = Cart.new
    # find an existing order and either load it or create one
    locate_order
    respond_to do |format|
      format.html {
        render :action => (params[:step] ? params[:step] : "new")
      }
    end
  end

  def create
    @cart = Cart.new( (params[:confirm] ? true : false) )
    locate_order
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
    locate_order
    redirect_to :action => 'new' unless @order.complete?
  end

  protected
  def ssl_required?
    true
  end
  
  def locate_order
    # need to check if there's an existing order for the session. If so, grab it and load it
    @order = Order.new({:donor_type => Order.personal_donor, :email => 'info@christmasfuture.org', :amount => @cart.total})
    @order.attributes = params[:order] if params[:order]
    @order
  end
end
