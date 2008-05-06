class Dt::CheckoutsController < DtApplicationController
  def new 
    @order = Order.new
    @cart = Cart.new
  end

  def create
    @order = Order.new(params[:order])
    @cart = Cart.new
    respond_to do |format|
      unless params[:confirm]
        # check for account creation
        # ...
        # process credit card
        # @order.save
        flash[:notice] = "Your account has been created" # if account_created?
        flash[:notice] << "<div>Your checkout is complete</div>"
      end
      format.html {
        if params[:confirm]
          render :action => "confirm"
        else
          redirect_to(dt_projects_path)
        end
      }
    end
  end

  protected
  def ssl_required?
    true
  end
end
