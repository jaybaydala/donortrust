require 'order_helper'

class Dt::GiftsController < DtApplicationController
  helper "dt/places"
  before_filter :login_required, :only => :unwrap
  before_filter :set_time_zone, :only => [ :create, :update ]
  before_filter :add_user_to_params, :only => [ :create, :update ]
  before_filter :find_cart
  include OrderHelper
  
  CANADA = 'canada'
  
  def index
    respond_to do |format|
      format.html { redirect_to :action => 'new' }
    end
  end

  def show
    @gift = Gift.find(:first, :conditions => ["id=? AND pickup_code=?", params[:id], params[:code]]) if params[:code]
    respond_to do |format|  
      if !@gift
        flash[:notice] = "That gift does not exist or has already been opened"
        redirect_to :action => 'new' and return
      end
      format.html
      format.pdf {
        pdf = @gift.pdf
        send_data pdf.render, :filename => pdf.filename, :type => "application/pdf"
        pdf.post_render
      }
    end
  end
  
  def new
    store_location
    load_ecards
    @gift = Gift.new(:e_card => @ecards.first)
    @gift.send_email = nil # so we can preselect "now" for delivery
    @gift.email = current_user.email if !@gift.email? && logged_in?
    
    if params[:project_id] && @project = Project.find(params[:project_id]) 
      if @project.fundable?
        @gift.project = @project
      else
        flash[:notice] = "The &quot;#{@project.name}&quot; is fully funded. Please choose another project."
        redirect_to dt_project_path(@project) and return
      end
    end
    
    if logged_in?
      @gift.write_attribute("email", current_user.email) unless @gift.email?
      @gift.write_attribute("name", current_user.full_name) unless @gift.name?
    end
    respond_to do |format|
      format.html {
        unless logged_in? && current_user.in_country?(CANADA)
          # MP Dec 14, 2007 - In order to support US donations, this was added to switch out the
          # layout of the Gift page. If the user's country is nil, not Canada or they're not logged_in,
          # use the layout that allows for US donations.
          render :layout => 'us_receipt_layout'
        else 
          render :action => 'new'
        end
      }
      format.js
    end
  end
  
  def create
    @gift = Gift.new( params[:gift] )
    @gift.user_ip_addr = request.remote_ip
    if params[:recipients] && !params[:recipients].empty?
      @gifts = []
      @errors = []
      email_parser = EmailParser.new(params[:recipients])
      email_parser.parse_list
      if email_parser.errors.empty?
        email_parser.emails.each do |email|
          gift = @gift.clone
          gift.to_name = email.name
          gift.to_email = email.address
          gift.to_email_confirmation = email.address
          @errors << gift unless gift.valid?
          @gifts << gift
        end
      end
      
      respond_to do |format|
        if @errors.empty? && email_parser.errors.empty?
          find_cart
          @gifts.each{|gift| @cart.add_item(gift)}
          flash[:notice] = "Your Gifts have been added to your cart."
          format.html { redirect_to dt_cart_path }
        else
          @gift = @gifts.first unless @gifts.empty?
          @gift.errors.add_to_base("There were some invalid email addresses in your recipient list. Please fix them to continue: <strong>#{email_parser.errors.join(', ')}</strong><br /><strong>Please Note:</strong> the list must be separated by commas") unless email_parser.errors.empty?
          @project = @gift.project if @gift.project_id? && @gift.project
          load_ecards
          format.html { render :action => "new" }
        end
      end
    else
      begin
        @valid = @gift.valid?
      rescue ActiveRecord::MultiparameterAssignmentErrors
        fix_date_params!
        @gift = Gift.new( params[:gift] )
        @gift.errors.add_to_base("Please choose a valid delivery date for your gift")
        @gift.user_ip_addr = request.remote_ip
        @valid = false
      end

      respond_to do |format|
        if @valid
          @cart.add_item(@gift)
          format.html { 
            flash[:notice] = "Your Gift has been added to your cart."
            redirect_to dt_cart_path
          }
          format.js
        else
          @project = @gift.project if @gift.project_id? && @gift.project
          load_ecards
          format.html { render :action => "new" }
          format.js
        end
      end  
    end
  end
  
  def edit
    if @cart.items[params[:id].to_i].kind_of?(Gift)
      @gift = @cart.items[params[:id].to_i]
      @project = @gift.project if @gift.project_id?
      if @gift.send_email_now
        @gift.send_email = nil # so we can preselect "now" for delivery
      end
      load_ecards
    end
    respond_to do |format|
      format.html {
        redirect_to dt_cart_path and return unless @gift
      }
    end
  end
  
  def update
    if @cart.items[params[:id].to_i].kind_of?(Gift)
      @gift = @cart.items[params[:id].to_i]
      begin
        @gift.attributes = params[:gift]
        @valid = @gift.valid?
      rescue ActiveRecord::MultiparameterAssignmentErrors
        fix_date_params!
        @gift.attributes = params[:gift]
        @gift.errors.add_to_base("Please choose a valid delivery date for your gift")
        @valid = false
      end
      @gift.user_ip_addr = request.remote_ip
    end
    
    respond_to do |format|
      if !@gift
        format.html { redirect_to dt_cart_path }
      elsif @valid
        @cart.update_item(params[:id], @gift)
        flash[:notice] = "Your Gift has been updated."
        format.html { redirect_to dt_cart_path }
      else
        @project = @gift.project if @gift.project_id?
        load_ecards
        format.html { render :action => "edit" }
      end
    end
  end
  
  def open
    store_location
    @gift = Gift.validate_pickup(params[:code]) if params[:code]
    respond_to do |format|
      format.html {
        if @gift
          if @gift.project_id?
            flash.now[:notice] = "You have been given #{number_to_currency(@gift.amount)}!" unless flash[:notice]
            @gift.pickup
          else
            @opening_now = true
            flash[:notice] = "Your Gift Card Balance is: #{number_to_currency(@gift.balance)}" unless @gift.project_id?
            # track some gift stuff in the session for cart and checkout
            session[:gift_card_id] = @gift.id
            session[:gift_card_balance] = @gift.balance
            # track it in a cookie as well for the blog site
            cookies[:gift_card_id] = @gift.id.to_s
            cookies[:gift_card_balance] = @gift.balance.to_s
            redirect_to dt_projects_path and return if params[:find] == "1"
            redirect_to new_dt_investment_path(:unallocated_gift => 1) and return if params[:unallocated_gift] == "1"
            redirect_to new_dt_account_deposit_path(current_user, :deposit => {:amount => number_to_currency(@gift.amount)}) and return if params[:deposit] == "1"
            redirect_to new_dt_investment_path(:admin_gift => 1) and return if params[:admin_gift] == "1"
          end
        elsif session[:gift_card_id]
          @gift = Gift.find(session[:gift_card_id])
        else
          flash.now[:error] = "The pickup code is not valid. Please check your email and try again." if params[:code]
        end
      }
    end
  end
  
  def unwrap
    @gift = Gift.validate_pickup(params[:code], params[:id])
    unless @gift
      flash[:notice] = "We could not find that gift"
      redirect_to :action => 'open' and return
    end
    respond_to do |format|
      order = Order.find_by_gift_card_payment_id(@gift.id)
      order = Order.create_order_with_investment_from_project_gift(@gift) unless order
      if order
        order.update_attributes(:user => current_user)
        order.investments.each do |i|
          i.update_attributes(:user => current_user)
        end
        flash[:notice] = "The project investment has been associated to your account."
      end
      format.html { redirect_to open_dt_gifts_path(:code => @gift.pickup_code) }
    end
  end

  def preview
    @gift = Gift.new( params[:gift] )
    # there are a couple of necessary field just for previewing - prefill them if they're empty
    @gift.email = "email@example.com" unless @gift.email?
    @gift.to_email = "to_email@example.com" unless @gift.to_email?
    @gift.pickup_code = '[pickup code]'
    @gift_mail = DonortrustMailer.create_gift_mail(@gift)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def confirm
  end

  protected
  def load_ecards 
    @ecards = ECard.find(:all, :order => :id)
    @ecards.unshift(@ecards.delete_at(2)) unless @ecards.empty? # changing the default image
  end
  
  def fix_date_params!
    params[:gift].delete_if{ |key,value| key.to_s[0,8] == "send_at(" }
  end
  def add_user_to_params
    unless params[:gift].nil?
      params[:gift][:user] = current_user if logged_in?
    end
  end
  
  
  
  def gift_params
    gift_params = {}
    gift_params = gift_params.merge(params[:gift]) if params[:gift]
    normalize_send_at!(gift_params)
    gift_params
  end
  
  
  
  def normalize_send_at!(gift_params)
    delete_send_at = false
    (1..5).each do |x|
      delete_send_at = true if gift_params["send_at(#{x}i)"] == '' || !gift_params["send_at(#{x}i)"]
    end
    if delete_send_at
      (1..5).each do |x|
        gift_params.delete("send_at(#{x}i)")
      end
    end
  end
  
  # this does the actually time-shifting for scheduling the gift?
  def set_time_zone
    Time.zone = params[:time_zone] if params[:time_zone]
  end
end
