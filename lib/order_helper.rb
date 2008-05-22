# this module is to be used as a mixin for controllers that need to use the cart or order
# currently, that includes Investments, Deposits, Gifts, Cart and Checkouts
module OrderHelper
  protected
  def find_cart
    session[:cart] = Cart.new unless session[:cart]
    @cart = session[:cart]
  end
  
  def find_order
    # need to check if there's an existing order for the session. If so, grab it and load it
    Order.find(session[:order_id])
  rescue
    return nil
  end
  
  def initialize_new_order
    @order = Order.new(params[:order])
    if logged_in?
      %w(first_name last_name email address city province postal_code country).each do |c|
        @order.write_attribute(c, current_user.read_attribute(c)) if @order.blank?(c)
      end
    end
    @order
  end
  
  def initialize_existing_order
    @order.attributes = params[:order]
    @order.total = @cart.total
    @order
  end
end
