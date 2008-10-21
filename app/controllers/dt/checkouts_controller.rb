require 'order_helper'
class Dt::CheckoutsController < DtApplicationController
  helper "dt/places"
  include OrderHelper
  before_filter :unallocated_gift, :only => :create
  before_filter :cart_empty?, :except => :show
  helper_method :current_step
  helper_method :next_step
  helper_method :account_payment?
  helper_method :gift_card_payment?
  helper_method :summed_account_balances
  
  CHECKOUT_STEPS = ["support", "billing", "payment", "confirm"]
  
  def new
    redirect_to(edit_dt_checkout_path) and return if find_order
    @order = initialize_new_order
    @cart_items = @cart.items.paginate(:page => params[:cart_page], :per_page => 5)
    respond_to do |format|
      format.html {
        @current_step = 'support'
        render :action => "new" 
      }
    end
  end
  
  def create
    redirect_to(edit_dt_checkout_path) and return if find_order
    @order = initialize_new_order
    unless params[:unallocated_gift].nil?
      gift = Gift.find(session[:gift_card_id])
      @order.email = gift.to_email
      unless gift.to_name.nil?
        to_name = gift.to_name.split(' ')
        @order.first_name = to_name[0]
        @order.last_name = to_name[1]
      end
    end
    @valid = validate_order
    do_action if params[:unallocated_gift].nil?
    @saved = @order.save if @valid
    # save our order_id in the session
    session[:order_id] = @order.id if @saved
    respond_to do |format|
      format.html { 
        if @saved
          redirect_to edit_dt_checkout_path(:step => "confirm") and return if params[:unallocated_gift]
          redirect_to edit_dt_checkout_path(:step => next_step) and return
        end
        render :action => "new"
      }
    end
  end
  
  def edit
    @order = find_order
    @cart_items = @cart.items.paginate(:page => params[:cart_page], :per_page => 5)
    redirect_to(new_dt_checkout_path) and return unless @order
    redirect_to(edit_dt_checkout_path(:step => CHECKOUT_STEPS[0])) and return unless current_step
    initialize_existing_order
    before_payment if current_step == "payment"
    before_billing if current_step == "billing"
    respond_to do |format|
      format.html {
        @current_step = current_step
        render :action => current_step
      }
    end
  end
  
  def update
    @order = find_order
    redirect_to(new_dt_checkout_path) and return unless @order
    redirect_to(edit_dt_checkout_path(:step => CHECKOUT_STEPS[0])) and return unless current_step
    initialize_existing_order
    @valid = validate_order
    begin
      do_action
    rescue ActiveMerchant::Billing::Error => err
      @payment_error = true
      @valid = false
      flash.now[:error] = "<strong>There was an error processing your credit card:</strong><br />#{err.message}"
    end
    @saved = @order.save if @valid
    respond_to do |format|
      format.html{
        if @saved 
          redirect_to dt_checkout_path(:order_number => @order.order_number) and return if @order.complete?
          @current_step = next_step
          before_billing if @current_step == "billing"
          before_payment if @current_step == "payment"
          render :action => next_step
        elsif @payment_error
          @current_step = 'payment'
          before_payment
          render :action => 'payment'
        else
          @current_step = current_step
          render :action => current_step
        end
      }
    end
  end
  
  def show
    @order = Order.find_by_order_number(params[:order_number]) if params[:order_number]
    redirect_to dt_cart_path and return unless @order
    redirect_to edit_dt_checkout_path and return unless @order.complete?
    redirect_to dt_cart_path and return unless session[:order_number].include?(params[:order_number].to_i)
  end
  
  def destroy
    @cart = find_cart
    @order = find_order
    @cart.empty! if params[:clear_cart]
    @order.destroy if @order
    session[:order_id] = nil
    flash[:notice] = "Your order has been cleared! Please add items to your cart to checkout." if params[:clear_cart]
    redirect_to dt_cart_path
  end

  protected
  def ssl_required?
    true
  end

  def account_payment?
    logged_in? and current_user.balance.to_f > 0
  end
  
  def gift_card_payment?
    session[:gift_card_balance] && session[:gift_card_balance].to_f > 0
  end
  
  def summed_account_balances
    balance = 0
    balance += current_user.balance if account_payment?
    balance += session[:gift_card_balance] if gift_card_payment?
    balance
  end
  
  
  def current_step
    return nil unless params[:step]
    return params[:step] if params[:step] && CHECKOUT_STEPS.include?(params[:step])
    return nil
  end
  
  def next_step
    next_step = CHECKOUT_STEPS[current_step ? CHECKOUT_STEPS.index(current_step)+1 : 0]
  end
  
  def validate_order
    user_balance = logged_in? ? current_user.balance : nil
    case current_step
      when "support"
        # no model validation to happen here
        @valid = true
      when "billing"
        @valid = @order.validate_billing
      when "payment"
        @valid = @order.validate_payment(@cart.items)
      when "confirm"
        @valid = @order.validate_confirmation(@cart.items)
    end
    @valid
  end

  def do_action
    case current_step
      when "support"
        do_support
      when "billing"
        do_billing
      when "payment"
        do_payment
      when "confirm"
        do_confirm
    end
  end
  
  def before_billing
    # load the info from the first gift into the billing fields
    gift = @cart.gifts.first if @cart.gifts.size > 0
    if gift
      @order.email = gift.email unless @order.email?
      first_name, last_name = gift.name.to_s.split(/ /, 2)
      @order.first_name = first_name unless @order.first_name?
      @order.last_name = last_name unless @order.last_name?
    end
  end
  
  def before_payment
    # remove the payment info so we never keep it around
    @order.card_number = nil
    @order.cvv = nil
    @order.expiry_month = nil
    @order.expiry_year = nil
    @order.cardholder_name = nil
  end

  def do_support
    if !params[:fund_cf].nil? && %w(dollars percent no).include?(params[:fund_cf]) && Project.admin_project
      @admin_project = Project.admin_project
      # delete the admin_project investment item - it will get re-added below, if applicable
      index = @cart.items.index(@cart.items.find{|item| item.class == Investment && item.project_id == @admin_project.id && item.checkout_investment? })
      @cart.remove_item(index) if index
      unless params[:fund_cf] == "no"
        @admin_investment = Investment.new(:project_id => @admin_project.id, :amount => params[:fund_cf_amount], :checkout_investment => true)
        @admin_investment.amount = @cart.total * (@admin_investment.amount/100) if params[:fund_cf] == "percent"
        @cart.add_item(@admin_investment) if @admin_investment.amount?
      end
    else
      @order.errors.add_to_base("Please choose if you would like to help cover our costs")
      @valid = false
    end
  end
  
  def do_billing
    # check if they want an account
    if params[:create_account]
      @user = User.new do |u|
        u.login = params[:order][:email]
        u.first_name = params[:order][:first_name]
        u.last_name = params[:order][:last_name]
        u.display_name = params[:order][:company]
        u.address = params[:order][:address]
        u.city = params[:order][:city]
        u.province = params[:order][:province]
        u.postal_code = params[:order][:postal_code]
        u.country = params[:order][:country]
        u.password = params[:password]
        u.password_confirmation = params[:password_confirmation]
        u.terms_of_use = params[:terms_of_use]
      end
      @valid = @user.valid?
      if @valid && @user.valid?
        flash[:notice] = 'Thanks for signing up! An activation email has been sent to your email address. This order will automatically be associated with your new account - you can finish the account activation process after checking out.'
        # create the account
        @user.save
        # and add the new user_id to the @order
        @order.user = @user
      end
    elsif !logged_in?
      flash.now[:notice] = "A user with your email address (#{@order.email}) already exists. To have this order associated with your account, login below and continue your checkout." if User.find_by_login(@order.email)
    end
  end
  
  def do_payment
    # nothing more to do here after the validation
  end
  
  def do_confirm
    if @valid
      Order.transaction do
        # process the credit card - should handle an exception here
        # if no exception, we're all good.
        # if there is, we should render the payment template and show the errors...
        transaction_successful = @order.credit_card_payment? ? @order.run_transaction : true
        if transaction_successful
          # auto-push the send_at dates into the future, wherever necessary, to avoid silly validation errors
          @cart.gifts.each{|gift| gift.send_at = Time.now + 1.minute if gift.send_at? && gift.send_at < Time.now}
          # save the cart items into the db via the association
          @order.gifts = @cart.gifts
          @order.investments = @cart.investments
          @order.deposits = @cart.deposits
          # add the gift_payment_id onto the order if a gift_card_payment is happening
          # set it to nil if there isn't
          if @order.gift_card_payment?
            @order.update_attributes!(:gift_card_payment_id => session[:gift_card_id])
            @gift_card = Gift.find(@order.gift_card_payment_id)
            @gift_card.balance = @gift_card.balance - @order.gift_card_payment
            @gift_card.save!
          end
          # mark the order as complete
          @order.update_attributes!(:complete => true)
        end
      end
    end
    if @order.complete?
      @cart.empty!
      # empty the order_id from the session
      session[:order_id] = nil
      # add the order number into the session so they can view their completed order(s) for the session
      session[:order_number] = [] unless session[:order_number]
      session[:order_number] << @order.order_number
      # empty the gift card from the session, if any
      if @gift_card
        if @gift_card.balance == 0
          session[:gift_card_id] = nil
          session[:gift_card_balance] = nil
          @gift_card.pickup
        else
          session[:gift_card_balance] = @gift_card.balance
          flash[:notice] = "Your gift card balance will expire on #{@gift_card.expiry_date.strftime("%b %e, %Y")}" if !@gift_card.expiry_date.nil?
        end
      end
    end
  end
  
  def cart_empty?
    @cart = find_cart
    if @cart.empty?
      flash[:notice] = "Your cart is currently empty, please add an item to your cart before checkout."
      redirect_to dt_cart_path
      return false
    end
    true
  end
  
  def unallocated_gift
    return true if params[:unallocated_gift].nil?
    @cart = find_cart
    if @cart.items.find {|item| item.class == Investment && item.project == Project.unallocated_project && item.amount == Gift.find(session[:gift_card_id]).balance}
      return true unless find_order
      redirect_to edit_dt_checkout_path(:step => "confirm") and return false
    end
    @investment = Investment.new( params[:investment])
    @investment.amount = Gift.find(session[:gift_card_id]).balance
    @investment.project = Project.unallocated_project
    @investment.user = current_user if logged_in?
    @investment.user_ip_addr = request.remote_ip

    @valid = @investment.valid?

    if @valid
      @cart.add_item(@investment)
    else
      flash.now[:error] = "There was a problem adding the Investment to your cart. Please review your information and try again."
    end
  end
end
