require 'order_helper'
class Dt::CheckoutsController < DtApplicationController
  helper "dt/places"
  include OrderHelper
  
  CHECKOUT_STEPS = ["payment", "confirm"]
  
  def new
    @cart = find_cart
    @order = find_order
    redirect_to(edit_dt_checkout_path) and return if @order
    @order = initialize_new_order
    respond_to do |format|
      if @cart.items.empty?
        flash[:notice] = "Your cart is currently empty, please add an item to your cart before checkout."
        redirect_to dt_cart_path and return
      end
      format.html { render :action => "new" }
    end
  end
  
  def create
    @cart = find_cart
    @order = find_order
    redirect_to(edit_dt_checkout_path) and return if @order
    @order = initialize_new_order
    @valid = validate_order
    @saved = @order.save if @valid
    # save our order_id in the session
    session[:order_id] = @order.id if @saved
    respond_to do |format|
      format.html { 
        redirect_to edit_dt_checkout_path(:step => next_step) and return if @saved
        render :action => "new"
      }
    end
  end
  
  def edit
    @cart = find_cart
    @order = find_order
    redirect_to(new_dt_checkout_path) and return unless @order
    initialize_existing_order
    if params[:step] == "payment"
      @order.credit_card = nil
      @order.csc = nil
    end
    respond_to do |format|
      format.html {
        if @cart.items.empty?
          flash[:notice] = "Your cart is currently empty, please add an item to your cart before checkout."
          redirect_to dt_cart_path and return
        end
        render :action => (current_step || "edit")
      }
    end
  end
  
  def update
    @cart = find_cart
    @order = find_order
    redirect_to(new_dt_checkout_path) and return unless @order
    initialize_existing_order
    
    @valid = validate_order
    
    if current_step.nil?
      do_billing
    elsif current_step == "payment"
      do_payment
    elsif current_step == "confirm"
      do_confirm
    end

    @saved = @order.save if @valid
    
    respond_to do |format|
      format.html{
        if @saved 
          if @order.complete?
            redirect_to dt_checkout_path(:order_number => @order.order_number) and return
          else
            redirect_to(edit_dt_checkout_path(:step => next_step))
          end
        else
          render :action => (current_step || "edit")
        end
      }
    end
  end
  
  def show
    # need to add an authorization check here.
    # either user_id (if it exists and they're logged_in?)
    # or session[:order_number].include?(params[:order_number])
    @order = Order.find_by_order_number(params[:order_number]) if params[:order_number]
    redirect_to dt_cart_path unless @order && @order.complete?
  end
  
  def destroy
    @cart = find_cart
    @order = find_order
    @cart.empty! if params[:clear_cart]
    @order.destroy if @order
    session[:order_id] = nil
    session[:credit_card] = nil
    flash[:notice] = "Your order has been cleared! Please add items to your cart to checkout." if params[:clear_cart]
    redirect_to dt_cart_path
  end

  protected
  def ssl_required?
    true
  end
  
  def do_billing
    # check if they want an account
    if params[:create_account]
      # if they do, check for an existing one
      existing_user = User.find_by_login(@order.email) if @order.email?
      @order.errors.add_to_base("That email address is already associated with an account. Please login") if existing_user
      # check the passwords
      @order.errors.add_to_base("You must enter a password for your new account") if params[:password].empty?
      @order.errors.add_to_base("Your passwords must match") unless params[:password] && params[:password] == params[:password_confirmation]
      # check the terms of use
      @order.errors.add_to_base("You must accept our Terms of Use to create an account") unless params[:terms_of_use]
      @valid = @order.errors.empty?
      if @valid
        # create the account
        # and add the new user_id to the @order
        flash[:notice] = 'Thanks for signing up! An activation email has been sent to your email address. This order will be associated with your new account - you can finish the account activation process after checking out.'
        user = User.new do |u|
          u.first_name = @order.first_name
          u.last_name = @order.last_name
          u.address = @order.address
          u.city = @order.city
          u.province = @order.province
          u.postal_code = @order.postal_code
          u.country = @order.country
          u.password = params[:password]
          u.password_confirmation = params[:password_confirmation]
          u.terms_of_use = params[:terms_of_use]
        end
        user.save
        @order.user_id = user
      end
    end
  end
  
  def do_payment
    if Project.cf_admin_project
      if !params[:fund_cf]
        @order.errors.add_to_base("Please choose if you would like to help cover our costs")
        @valid = false
      else
        if params[:fund_cf] == 'percent'
          cf_amount = @cart.total * (params[:fund_cf_amount].to_f/100)
        elsif params[:fund_cf] == 'dollars'
          cf_amount = params[:fund_cf_amount]
        else
          @cart.remove_item(@cart.cf_investment_index) if @cart.cf_investment
        end
        if cf_investment = @cart.cf_investment
          cf_investment.amount = cf_amount
          @cart.update_item(@cart.cf_investment_index, cf_investment)
        else
          cf_investment = Investment.new(:project_id => Project.cf_admin_project.id, :amount => cf_amount)
          @cart.add_item(cf_investment)
        end
      end
    end
    # save the credit card until payment is complete
    session[:credit_card] = params[:credit_card] if @saved &&  @order.credit_card?
  end
  
  def do_confirm
    Order.transaction do
      # process the credit card
      
      
      # save the cart items into the db via the association
      @cart.gifts.each{|gift| @order.gifts << gift }
      @cart.investments.each{|investment| @order.investments << investment }
      @cart.deposits.each{|deposit| @order.deposits << deposit }
      
      # create the tax receipt
      @order.create_tax_receipt_from_order
      
      # mark the order as complete
      @order.update_attributes(:complete => true)
    end
    if @order.complete?
      # empty the cart
      @cart.empty!
      # empty the credit card from the session - we won't need it anymore
      session[:credit_card] = nil 
      # empty the order_id from the session
      session[:order_id] = nil
      # add the order number into the session so they can view their completed order(s) for the session
      session[:order_number] = [] unless session[:order_number]
      session[:order_number] << @order.order_number
    end
  end
  
  def validate_order
    user_balance = logged_in? ? current_user.balance : nil
    if current_step.nil?
      @valid = @order.validate_billing
    elsif current_step == 'payment'
      @valid = @order.validate_payment(@cart.minimum_credit_card_payment, user_balance)
    elsif current_step == 'confirm'
      @valid = @order.validate_confirmation
    elsif current_step == 'complete'
      @valid = @order.validate_billing && @order.validate_confirmation && @order.validate_payment(@cart.minimum_credit_card_payment, user_balance)
    end
    @valid
  end
  
  def current_step
    return nil if !params[:step]
    return params[:step] if params[:step] && CHECKOUT_STEPS.include?(params[:step])
    return "complete"
  end
  
  def next_step
    if !current_step
      next_step = CHECKOUT_STEPS[0]
    else
      next_step = CHECKOUT_STEPS[CHECKOUT_STEPS.index(current_step)+1]
      next_step = "complete" if !next_step
    end
    next_step
  end
end
