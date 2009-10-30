require 'order_helper'
class Dt::CheckoutsController < DtApplicationController
  helper "dt/places"
  include OrderHelper
  before_filter :directed_gift, :only => :update
  before_filter :cart_empty?, :except => :show
  helper_method :current_step
  helper_method :next_step
  helper_method :account_payment?
  helper_method :gift_card_payment?
  helper_method :summed_account_balances
  
  CHECKOUT_STEPS = ["support", "payment", "billing", "confirm"]
  
  def new
    redirect_to(edit_dt_checkout_path) and return if find_order
    @current_step = CHECKOUT_STEPS[0]
    @order = initialize_new_order
    paginate_cart
    respond_to do |format|
      format.html {
        @current_nav_step = current_step
        render :action => "new" 
      }
    end
  end
  
  def create
    redirect_to(edit_dt_checkout_path) and return if find_order
    @current_step = CHECKOUT_STEPS[0]
    @order = initialize_new_order
    paginate_cart
    if !params[:unallocated_gift].nil? && !params[:admin_gift].nil? && !params[:directed_gift].nil?
      gift = Gift.find(session[:gift_card_id])
    end
    @valid = validate_order
    do_action if params[:unallocated_gift].nil? && params[:admin_gift].nil? && params[:directed_gift].nil?
    @saved = @order.save if @valid
    # save our order_id in the session
    session[:order_id] = @order.id if @saved
    respond_to do |format|
      format.html {
        if @saved
          @current_step = CHECKOUT_STEPS[2] if params[:unallocated_gift] == "1" || params[:admin_gift] == "1"
          redirect_to edit_dt_checkout_path(:step => next_step) and return
        end
        @current_nav_step = current_step
        render :action => "new"
      }
    end
  end
  
  def edit
    @order = find_order
    paginate_cart
    
    # puts "Did we find the order? " + (!@order.nil?).to_s

    redirect_to(new_dt_checkout_path) and return unless @order
    # puts "current_step: " + @current_step.to_s

    redirect_to(edit_dt_checkout_path(:step => CHECKOUT_STEPS[0])) and return unless current_step
    initialize_existing_order
    before_payment if current_step == "payment"
    before_billing if current_step == "billing"
    respond_to do |format|
      format.html {
        @current_nav_step = current_step
        render :action => current_step
      }
    end
  end
  
  def update
    @order = find_order
    paginate_cart
    redirect_to(new_dt_checkout_path) and return unless @order
    redirect_to(edit_dt_checkout_path(:step => CHECKOUT_STEPS[0])) and return unless current_step
    initialize_existing_order
    @valid = validate_order

    begin
      do_action
    rescue ActiveMerchant::Billing::Error => err
      @billing_error = true
      @valid = false
      flash[:error] = "<strong>There was an error processing your credit card:</strong><br />#{err.message}"
    end
    @saved = @order.save if @valid
    respond_to do |format|
      format.html{
        redirect_to edit_dt_checkout_path(:step => "billing") and return if @billing_error
        if @saved
          if @order.complete?
            show_params = {}
            show_params[:directed_gift] = 1 if @directed_gift
            show_params[:order_number] = @order.order_number
            redirect_to dt_checkout_path(show_params) and return
          elsif @directed_gift
            flash[:error] = "You have more items in your cart than your gift card can cover. Please go through the normal checkout process - you can still use the balance of your gift card when you checkout."
            redirect_to edit_dt_checkout_path(:step => CHECKOUT_STEPS[0]) and return
          end
          before_billing if next_step == "billing"
          before_payment if next_step == "payment"
          @current_nav_step = next_step
          # redirect_to edit_dt_checkout_path(:step => next_step) and return
          render :action => next_step and return
        elsif @billing_error
          @current_step = 'billing'
          before_billing
        end
        @current_nav_step = current_step
        render :action => current_step
        # redirect_to edit_dt_checkout_path(:step => current_step)
      }
    end
  end
  
  def show
    @order = Order.find_by_order_number(params[:order_number]) if params[:order_number]
    @directed_gift = params[:directed_gift] ? true : false
    if @directed_gift
      @project = @order.investments.first.project
    end
    redirect_to dt_cart_path and return unless @order
    redirect_to edit_dt_checkout_path and return unless @order.complete?
    redirect_to dt_cart_path and return unless session[:order_number] && session[:order_number].include?(params[:order_number].to_i)
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
  
  attr_accessor :current_step
  def current_step
    if @current_step.nil?
      @current_step = nil unless params[:step]
      @current_step = params[:step] if params[:step] && CHECKOUT_STEPS.include?(params[:step])
    end
    @current_step
  end
  
  def next_step
    CHECKOUT_STEPS[current_step ? CHECKOUT_STEPS.index(current_step)+1 : 0]
  end
  
  def validate_order
    user_balance = logged_in? ? current_user.balance : nil
    case current_step
      when "support"
        # no model validation to happen here
        @valid = true
      when "payment"
        @valid = @order.validate_payment(@cart.items)
      when "billing"
        @valid = @order.validate_billing(@cart.items)
      when "confirm"
        @valid = @order.validate_confirmation(@cart.items)
    end
    @valid
  end

  def do_action
    logger.debug("current_step: #{current_step}")
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
  
  def before_payment
    # remove the payment info so we never keep it around
    @order.card_number = nil
    @order.cvv = nil
    @order.expiry_month = nil
    @order.expiry_year = nil
    @order.cardholder_name = nil
  end

  def before_billing
    # load the info from the first gift into the billing fields
    # gift = @cart.gifts.first if @cart.gifts.size > 0
    # if gift
    #   @order.email = gift.email unless @order.email?
    #   first_name, last_name = gift.name.to_s.split(/ /, 2)
    #   @order.first_name = first_name unless @order.first_name?
    #   @order.last_name = last_name unless @order.last_name?
    # end
  end
  
  def do_support
    if !params[:fund_cf].nil? && %w(dollars percent no).include?(params[:fund_cf]) && Project.admin_project
      @admin_project = Project.admin_project
      # delete the admin_project investment item - it will get re-added below, if applicable
      index = @cart.items.index(@cart.items.detect{|item| item.class == Investment && item.project_id == @admin_project.id && item.checkout_investment? })
      @cart.remove_item(index) unless index.nil?
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
        if @cart.subscription?
          @subscription = Subscription.create_from_cart_and_order(@cart, @order)
          @order.update_attribute(:subscription_id, @subscription.id)
        end
        transaction_successful = @order.credit_card_payment? ? @order.run_transaction : true
        # clear the tmp_card_number every time
        # @order.update_attribute(:tmp_card_number, nil) if @order.tmp_card_number?
        # params[:order][:tmp_card_number] = nil
        if transaction_successful
          @cart.update_attribute(:order_id, @order.id)
          # auto-push the send_at dates into the future, wherever necessary, to avoid silly validation errors
          @cart.gifts.each{|gift| gift.send_at = Time.now + 1.minute if gift.send_email? && (!gift.send_at? || (gift.send_at? && gift.send_at < Time.now)) }
          # save the cart items into the db via the association
          @cart.pledges.each{|pledge| pledge.update_attributes(:paid => true)}

          @order.gifts = @cart.gifts
          @order.investments = @cart.investments
          @order.deposits = @cart.deposits
          @order.pledges = @cart.pledges

          if @order.registration_fee_id? && @order.registration_fee
            logger.debug "Order: #{@order.inspect}"
            logger.debug "Registration Fee: #{@order.registration_fee.inspect}"
            participant = Participant.create_from_unpaid_participant!(@order.registration_fee.participant_id)
            registration_fee = @order.registration_fee
            registration_fee.paid = true
            registration_fee.participant_id = participant.id
            registration_fee.save!
            registration_fee.save_transaction
          end

          # pre-create a new order (with investment) for any project gifts
          @order.gifts.each {|gift| Order.create_order_with_investment_from_project_gift(gift) }

          # add the gift_payment_id onto the order if a gift_card_payment is happening
          # set it to nil if there isn't
          if @order.gift_card_payment?
            @order.update_attributes!(:gift_card_payment_id => session[:gift_card_id])
            @gift_card = Gift.find(@order.gift_card_payment_id)
            @gift_card.balance = @gift_card.balance - @order.gift_card_payment
            @gift_card.save!
          end

          # reduce the pledge_account_payment balance if a pledge_account_payment
          # set it to nil if there isn't
          if logged_in? && @order.pledge_account_payment? && @order.pledge_account_payment_id?
            @pledge_account = PledgeAccount.find(@order.pledge_account_payment_id, :conditions => {:user_id => current_user})
            @pledge_account.balance = @pledge_account.balance - @order.pledge_account_payment
            @pledge_account.save!
          end
          if !@pledge_account
            @order.update_attributes(:pledge_account_payment => nil, :pledge_account_payment_id => nil) 
          end

          # mark the order as complete
          @order.update_attributes!(:complete => true)
        end
      end
    end
    if @order.complete?
      # empty the cart_id from the session
      session[:cart_id] = nil
      # empty the order_id from the session
      session[:order_id] = nil
      # add the order number into the session so they can view their completed order(s) for the session
      session[:order_number] = [] unless session[:order_number]
      session[:order_number] << @order.order_number
      # deal with the gift card
      if @gift_card
        if @gift_card.balance == 0
          @gift_card.pickup # this sends the notify email and disallows the gift from being opened again
          session[:gift_card_id] = nil
          session[:gift_card_balance] = nil
        else
          session[:gift_card_balance] = @gift_card.balance
          flash[:notice] = "Please note: Your gift card balance will expire on #{@gift_card.expiry_date.strftime("%b %e, %Y")}. If you need more time, please <a href=\"#{new_dt_account_deposit_path(current_user, :deposit => {:amount => @gift_card.balance})}\">Deposit the balance</a> into your account." if !@gift_card.expiry_date.nil?
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
  
  def directed_gift
    @directed_gift = false
    return true if (params[:unallocated_gift].nil? || params[:unallocated_gift].empty?) && 
                   (params[:admin_gift].nil? || params[:admin_gift].empty?) && 
                   (params[:directed_gift].nil? || params[:directed_gift].empty?)
    @cart = find_cart
    if params[:unallocated_gift] == "1"
      project = Project.unallocated_project
    elsif params[:admin_gift] == "1"
      project = Project.admin_project
    elsif params[:directed_gift] == "1"
      project = Project.find(params[:gift_project]);
    end
    if @cart.items.detect {|item| item.class == Investment && item.project == project && item.amount == Gift.find(session[:gift_card_id]).balance}
      return true if find_order
      redirect_to new_dt_checkout_path and return false
    end
    @investment = Investment.new( params[:investment])
    @investment.amount = Gift.find(session[:gift_card_id]).balance
    @investment.project = project
    @investment.user = current_user if logged_in?
    @investment.user_ip_addr = request.remote_ip

    @valid_investment = @investment.valid?


    if @valid_investment
      @directed_gift = true
      @current_step = 'confirm'
      @cart.add_item(@investment)
      @order = initialize_new_order
      @valid = validate_order
      @saved = @order.save if @valid
      # save our order_id in the session
      session[:order_id] = @order.id if @saved
    end
  end

  protected
    def paginate_cart
      @cart_items = @cart.items.paginate(:page => params[:cart_page], :per_page => 5)
    end

    ExceptionNotifier.sections << "cart"
    exception_data :additional_data
    def additional_data
      { :cart => @cart }
    end

end
