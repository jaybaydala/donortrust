# this module is to be used as a mixin for controllers that need to use the cart or order
# currently, that includes Investments, Deposits, Gifts, Cart and Checkouts
module OrderHelper
  protected
  def find_cart
    if session[:cart_id]
      @cart ||= Cart.find(session[:cart_id])
    else
      cart_attributes = {}
      cart_attributes[:user_id] = current_user.id if logged_in?
      @cart = Cart.create(cart_attributes)
      session[:cart_id] = @cart.id
    end
    @cart.update_attribute(:user_id, current_user.id) if !@cart.user_id && logged_in?
    @cart.update_attribute(:subscription, params[:subscription]) if params[:subscription]
    @cart
  end
  
  def find_order
    begin
      # need to check if there's an existing order for the session. If so, grab it and load it
      Order.find(session[:order_id])
    rescue
      return nil
    end
  end
  
  def initialize_new_order
    @cart = find_cart unless @cart
    @order = Order.new(params[:order])
    @order.account_balance = current_user.balance if logged_in?
    @order.gift_card_balance = session[:gift_card_balance] if session[:gift_card_balance]
    load_user_data_into_order
    @order.total = @cart.total
    ############
    # THE GIFT_CARD_PAYMENT AND CREDIT_CARD_PAYMENT SHOULD ONLY BE SET ONCE
    # set the gift card payment
    unless @order.total_payments == @order.total
      if session[:gift_card_balance] && session[:gift_card_balance] > 0 && !@order.gift_card_payment?
        @order.gift_card_payment = @order.total && session[:gift_card_balance] > @order.total ? @order.total : session[:gift_card_balance]
      end
      # set the credit card payment
      unless @order.credit_card_payment?
        unless logged_in? && @order.account_balance && (@order.account_balance > 0)
          @order.credit_card_payment = @order.gift_card_payment? ? @order.total - @order.gift_card_payment : @order.total
          @order.credit_card_payment = 0 if @order.credit_card_payment? && @order.credit_card_payment < 0
        end
      end
    end
    @order
  end
  
  def initialize_existing_order
    @order = find_order unless @order
    @cart = find_cart unless @cart
    return nil unless @order && @cart
    load_user_data_into_order
    @order.attributes = params[:order]
    @order.total = @cart.total
    # add in the pledge_account_balance
    if logged_in? && params[:order] && params[:order][:pledge_account_payment_id] && pledge_account = PledgeAccount.find(params[:order][:pledge_account_payment_id], :conditions => {:user_id => current_user})
      @order.pledge_account_balance = pledge_account.balance if pledge_account
    end
    @order.user = current_user if logged_in?
    @order
  end
  
  def load_user_data_into_order
    if logged_in?
      %w(first_name last_name address city province postal_code country).each do |c|
        @order.write_attribute(c, current_user.read_attribute(c)) unless @order.attribute_present?(c)
      end
      @order.email = current_user.login unless @order.email?
      @order.user = current_user unless @order.user_id? && @order.user
    end
  end
end
