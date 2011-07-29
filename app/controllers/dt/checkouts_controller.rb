require 'order_helper'
class Dt::CheckoutsController < DtApplicationController
  helper "dt/places"
  include OrderHelper
  before_filter :directed_gift, :only => :update
  before_filter :cart_empty?, :except => :show
  before_filter :set_checkout_steps, :except => :show
  helper_method :current_step
  helper_method :next_step
  helper_method :account_payment?
  helper_method :gift_card_balance?
  helper_method :summed_account_balances

  def new
    redirect_to(edit_dt_checkout_path) and return if find_order
    @current_step = @checkout_steps[0]
    @order = initialize_new_order
    paginate_cart
    respond_to do |format|
      format.html {
        if @cart.subscription?
          @valid = validate_order
          @order.credit_card_payment = @cart.total
          @saved = @order.save if @valid
          session[:order_id] = @order.id if @saved
          redirect_to edit_dt_checkout_path(:step => @checkout_steps[1]) and return 
        end
        @current_nav_step = current_step
        render :action => @checkout_steps[0]
      }
    end
  end

  def create
    redirect_to(edit_dt_checkout_path) and return if find_order
    @current_step = @checkout_steps[0]
    @order = initialize_new_order
    @order.attributes = params[:order]
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
          @current_step = @checkout_steps[1] if params[:unallocated_gift] == "1" || params[:admin_gift] == "1"
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
    redirect_to(new_dt_checkout_path) and return unless @order
    redirect_to(edit_dt_checkout_path(:step => @checkout_steps[0])) and return unless current_step
    initialize_existing_order
    before_payment if current_step == "payment"
    respond_to do |format|
      format.html {
        if @cart.subscription? && @checkout_steps.index(current_step) < 1
          flash[:notice] = "You only need to enter your Billing Information for monthly giving."
          redirect_to edit_dt_checkout_path(:step => @checkout_steps[1]) and return
        end
        @current_nav_step = current_step
        render :action => current_step
      }
    end
  end

  def update
    @order = find_order
    redirect_to(new_dt_checkout_path) and return unless @order
    redirect_to(edit_dt_checkout_path(:step => @checkout_steps[0])) and return unless current_step
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
        redirect_to edit_dt_checkout_path(:step => "credit_card") and return if @billing_error
        if @saved
          if @order.complete?
            show_params = {}
            show_params[:directed_gift] = 1 if @directed_gift
            show_params[:order_number] = @order.order_number
            redirect_to dt_checkout_path(show_params) and return
          elsif @directed_gift
            flash[:error] = "You have more items in your cart than your gift card can cover. Please go through the normal checkout process - you can still use the balance of your gift card when you checkout."
            redirect_to edit_dt_checkout_path(:step => @checkout_steps[0]) and return
          end
          before_payment if next_step == "payment"
          @current_nav_step = next_step
          # redirect_to edit_dt_checkout_path(:step => next_step) and return
          render :action => next_step and return
        elsif @billing_error
          @current_step = 'credit_card'
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
  
    def gift_card_balance?
      session[:gift_card_balance] && session[:gift_card_balance].to_f > 0
    end
  
    def summed_account_balances
      balance = 0
      balance += current_user.balance if account_payment?
      balance += session[:gift_card_balance] if gift_card_balance?
      balance
    end
  
    attr_accessor :current_step
    def current_step
      if @current_step.nil?
        @current_step = nil unless params[:step]
        @current_step = params[:step] if params[:step] && @checkout_steps.include?(params[:step])
      end
      @current_step
    end
  
    def next_step
      @checkout_steps[current_step ? @checkout_steps.index(current_step)+1 : 0]
    end
  
    def validate_order
      user_balance = logged_in? ? current_user.balance : nil
      case current_step
        when "payment_options"
          @order.payment_options_step = true
        when "billing"
          @order.billing_step = true
        when "account_signup"
          @order.account_signup_step = true
        when "credit_card"
          @order.credit_card_step = true
      end
      @order.valid?
    end

    def do_action
      logger.debug("current_step: #{current_step}")
      case current_step
        when "payment_options"
          @order.payment_options_step = true
        when "billing"
          @order.billing_step = true
          do_billing
        when "account_signup"
          @order.account_signup_step = true
        when "credit_card"
          @order.credit_card_step = true
      end
      do_confirm

    end

    def before_payment
      # remove the payment info so we never keep it around
      @order.card_number = nil
      @order.cvv = nil
      @order.expiry_month = nil
      @order.expiry_year = nil
      @order.cardholder_name = nil
    end

    def do_billing
      if !logged_in? && (@cart.subscription? || @order.tax_receipt_requested?)
        user = @order.create_user_from_order
        if user && !user.new_record?
          @order.user = user
          self.current_user = user
          flash[:notice] = "Your user has been created and you are now logged in"
        end
      end
      
      if !logged_in?
        flash.now[:notice] = "A user with your email address (#{@order.email}) already exists. To have this order associated with your account, login below and continue your checkout." if User.find_by_login(@order.email)
      end
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
            # remove the donation if this is a directed gift (a gift card redemption)
            remove_cart_donation if self.directed_gift? && @cart.donation
            # remove the donation if it's a $0 donation amount since that makes an invalid investment
            remove_cart_donation if @cart.donation && (@cart.donation.item.blank? || (@cart.donation.item.present? && @cart.donation.item.amount == 0))

            # auto-push the send_at dates into the future, wherever necessary, to avoid silly validation errors
            @cart.gifts.each{|gift| gift.send_at = Time.now + 1.minute if gift.send_email? && (!gift.send_at? || (gift.send_at? && gift.send_at < Time.now)) }
            # save the cart items into the db via the association
            @cart.pledges.each{|pledge| pledge.update_attributes(:paid => true)}
          
            @order.gifts = @cart.gifts
            @order.investments = @cart.investments
            @order.deposits = @cart.deposits
            @order.pledges = @cart.pledges
            if logged_in?
              @order.gifts.each{|gift| gift.update_attribute(:user_id, current_user.id)}
              @order.investments.each{|investment| investment.update_attribute(:user_id, current_user.id)}
              @order.deposits.each{|deposit| deposit.update_attribute(:user_id, current_user.id)}
              @order.pledges.each{|pledge| pledge.update_attribute(:user_id, current_user.id)}
            end

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
      return true if !self.directed_gift?
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

    def remove_cart_donation
      @cart.donation.destroy
      @cart.reload
      @cart.items.reload
    end

    def paginate_cart
      @cart_items = @cart.items.paginate(:page => params[:cart_page], :per_page => 5)
    end

    ExceptionNotifier.sections << "cart"
    exception_data :additional_data
    def additional_data
      { :cart => @cart }
    end

    def directed_gift?
      params[:unallocated_gift].present? || params[:admin_gift].present? || params[:directed_gift].present?
    end

    protected
      def set_checkout_steps
        @checkout_steps = []
        @checkout_steps << 'payment_options' if logged_in? && (current_user.balance > 0 || current_user.cf_admin?)
        @checkout_steps << 'billing'
        @checkout_steps << 'account_signup' unless logged_in?
        @checkout_steps << 'credit_card'
        @checkout_steps << 'receipt'
        @checkout_steps
      end

end
