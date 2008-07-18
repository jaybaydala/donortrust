require 'order_helper'
require 'pdf_proxy'

class Dt::GiftsController < DtApplicationController
  helper "dt/places"
  before_filter :login_required, :only => :unwrap
  include OrderHelper
  include PDFProxy
  
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
        proxy = create_pdf_proxy(@gift)
        send_data proxy.render, :filename => proxy.filename, :type => "application/pdf"
      }
    end
  end
  
  def new
    store_location
    params[:gift] = session[:gift_params] if session[:gift_params]
    @gift = Gift.new( gift_params )
    @gift.send_email = nil # so we can preselect "now" for delivery
    @gift.email = current_user.email if !@gift.email? && logged_in?
    @ecards = ECard.find(:all, :order => :id)
    
    if params[:project_id] && @project = Project.find(params[:project_id]) 
      if @project.fundable?
        @gift.project = @project
      else
        flash[:notice] = "The &quot;#{@project.name}&quot; is fully funded. Please choose another project."
        redirect_to dt_project_path(@project) and return
      end
    end
    
    if logged_in?
      %w( email first_name last_name address city province postal_code country).each do |c| 
        @gift.write_attribute(c, current_user.read_attribute(c)) unless @gift.attribute_present?(c)
      end
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
    end
  end
  
  def create
    @gift = Gift.new( gift_params )    
    @gift.user_ip_addr = request.remote_ip
    set_send_now_delivery!
    
    @valid = @gift.valid?

    respond_to do |format|
      if @valid
        session[:gift_params] = nil
        @cart = find_cart
        @cart.add_item(@gift)
        flash[:notice] = "Your Gift has been added to your cart."
        format.html { redirect_to dt_cart_path }
      else
        @project = @gift.project if @gift.project_id? && @gift.project
        @ecards = ECard.find(:all, :order => :id)
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @cart = find_cart
    if @cart.items[params[:id].to_i].kind_of?(Gift)
      @gift = @cart.items[params[:id].to_i]
      @project = @gift.project if @gift.project_id?
      @ecards = ECard.find(:all, :order => :id)
    end
    respond_to do |format|
      format.html {
        redirect_to dt_cart_path and return unless @gift
      }
    end
  end
  
  def update
    @cart = find_cart
    if @cart.items[params[:id].to_i].kind_of?(Gift)
      @gift = @cart.items[params[:id].to_i]
      @gift.attributes = params[:gift]
      @gift.user_ip_addr = request.remote_ip
      set_send_now_delivery!
      @valid = @gift.valid?
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
        @ecards = ECard.find(:all, :order => :id)
        format.html { render :action => "edit" }
      end
    end
  end
  
  def open
    store_location
    @gift = Gift.validate_pickup(params[:code]) if params[:code]
    respond_to do |format|
      flash.now[:error] = 'The pickup code is not valid. Please check your email and try again.' if params[:code] && !@gift
      format.html
    end
  end
  
  def unwrap
    @gift = Gift.validate_pickup(params[:gift][:pickup_code], params[:id])
    redirect_to :action => 'open' and return if !@gift
    @gift.pickup
    respond_to do |format|
      if @gift.picked_up?
        logger.debug "STARTING UNWRAP TRANSACTION"
        Gift.transaction do
          logger.debug "CREATING DEPOSIT"
          @deposit = Deposit.new_from_gift(@gift, current_user.id)
          @deposit.user_ip_addr = request.remote_ip
          @deposit.save!
          logger.debug "CREATING INVESTMENT"
          @investment = Investment.new_from_gift(@gift, current_user.id) if @gift.project_id
          @investment.user_ip_addr = request.remote_ip if @investment
          @investment.save! if @investment
        end
        logger.debug "FINISHING UNWRAP TRANSACTION"
        format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash[:error] = 'Your gift couldn\'t be picked up at this time. Please recheck your code and try again.'
        format.html { redirect_to :action => 'open' }
      end
    end
  end

  def preview
    @gift = Gift.new( gift_params )
    # there are a couple of necessary field just for previewing - prefill them
    %w( email to_email ).each do |field|
      @gift.send("#{field}=", "#{field}@example.com") unless @gift.send(field + '?')
    end
    @gift.pickup_code = '[pickup code]'
    @gift_mail = DonortrustMailer.create_gift_mail(@gift)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  protected
  def set_send_now_delivery!
    if params[:gift] && params[:gift][:send_email] && params[:gift][:send_email] == "now"
      @gift.send_email = true
      @gift.send_at = Time.now + 5.minutes
    end
  end
  
  def gift_params
    gift_params = {}
    gift_params = gift_params.merge(params[:gift]) if params[:gift]
    gift_params[:user] = current_user if logged_in?
    normalize_send_at!(gift_params)
    gift_params
  end
  
  def schedule(gift)
    send_at_vals = Array.new
    (1..5).each do |x|
      send_at_vals << params[:gift]["send_at(#{x}i)"] if params[:gift]["send_at(#{x}i)"] && params[:gift]["send_at(#{x}i)"] != ""
    end
    @send_at = Time.utc(send_at_vals[0], send_at_vals[1], send_at_vals[2], send_at_vals[3], send_at_vals[4]) if send_at_vals.length == 5
    gift.send_at = @send_at
    if gift.send_at && params[:time_zone] && params[:time_zone] != ''
      gift.send_at = gift.send_at + -(TimeZone.new(params[:time_zone]).utc_offset)
    end
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
end
