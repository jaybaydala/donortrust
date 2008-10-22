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
    @order.order_number = Order.generate_order_number
    @order.account_balance = current_user.balance if logged_in?
    @order.gift_card_balance = session[:gift_card_balance] if session[:gift_card_balance]
    if logged_in?
      %w(first_name last_name address city province postal_code country).each do |c|
        @order.write_attribute(c, current_user.read_attribute(c)) unless @order.attribute_present?(c)
      end
      @order.email = current_user.login
      @order.user = current_user
    end
    @order
  end
  
  def initialize_existing_order
    @order = find_order unless @order
    @cart = find_cart unless @cart
    return nil unless @order && @cart
    @order.attributes = params[:order]
    @order.total = @cart.total
    @order.user = current_user if logged_in?
    
    ############
    # THE GIFT_CARD_PAYMENT AND CREDIT_CARD_PAYMENT SHOULD ONLY BE SET IF THEY'RE NOT ALREADY...
    # set the gift card payment
    @order.gift_card_payment = session[:gift_card_balance] if !@order.gift_card_payment? && session[:gift_card_balance] && session[:gift_card_balance] > 0
    # set the credit card payment
    unless logged_in? && current_user.balance > 0
      @order.credit_card_payment = @order.gift_card_payment? ? @order.total - @order.gift_card_payment : @order.total
    end
    #if @order.gift_card_payment? && @order.gift_card_payment > @order.total
    #  @order.gift_card_payment = @order.total
    #  @order.credit_card_payment = 0
    #end
    @order
  end
end
