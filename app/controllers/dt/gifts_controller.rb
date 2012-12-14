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
    load_ecards
    @gift = Gift.new(:e_card => @ecards.first)
    @gift.email = current_user.email if !@gift.email? && logged_in?
    @gift.name = current_user.full_name if !@gift.name? && logged_in?
    @gift.notify_giver = true
    @gift.send_email = "now"
    if params[:sector_id] && @sector = Sector.find(params[:sector_id])
      @gift.sector_id = @sector_id
    elsif params[:project_id] && @project = Project.for_country(country_code).find(params[:project_id])
      if @project.fundable?
        @gift.project = @project
      else
        flash.now[:notice] = "The &quot;#{@project.name}&quot; is fully funded. Please choose another project."
      end
    end

    # Is this gift being given as a result of a promotion?
    if params[:promotion_id] && Promotion.exists?(params[:promotion_id])
      @gift.promotion_id = params[:promotion_id]
    end

    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def create
    @gift = Gift.new( params[:gift] )
    @gift.user_ip_addr = request.remote_ip
    if params[:recipients] && !params[:recipients].empty?
      @gifts = []
      @errors = []
      email_parser = EmailParser.new(params[:recipients], params[:remove_dups] == '1')
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
      respond_to do |format|
        if @gift.valid?
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
    if @cart.items.find(params[:id]).item.kind_of?(Gift)
      @gift = @cart.items.find(params[:id]).item
      @project = @gift.project if @gift.project_id?
      load_ecards
    end
    respond_to do |format|
      format.html {
        redirect_to dt_cart_path and return unless @gift
      }
    end
  end

  def update
    if @cart.items.find(params[:id]).item.kind_of?(Gift)
      @gift = @cart.items.find(params[:id]).item
      @gift.attributes = params[:gift]
      @gift.user_ip_addr = request.remote_ip
    end

    respond_to do |format|
      if !@gift
        format.html { redirect_to dt_cart_path }
      elsif @gift.valid?
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
            redirect_to new_iend_user_deposit_path(current_user, :deposit => {:amount => number_to_currency(@gift.amount)}) and return if params[:deposit] == "1"
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

  def match
    @gift = Gift.find(session[:gift_card_id])
    session[:gift_card_balance] = @gift.balance * 2
    session[:gift_matched] = true
  end

  def unwrap
    @gift = Gift.find(params[:id])
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
