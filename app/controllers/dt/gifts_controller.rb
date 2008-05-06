require 'iats/iats_process.rb'
require 'pdf_proxy'
include PDFProxy

class Dt::GiftsController < DtApplicationController
  helper "dt/places"
  include IatsProcess
  include FundCf
  before_filter :login_required, :only => :unwrap
  
  #helper for testing purposes since I couldn't figure out
  #how to determine in the tests whether a certain layout was being used
  attr_accessor :using_us_layout
  
  CANADA = 'canada'
  
  def initialize
    super
    @page_title = "Gift It!"
  end
  
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
    self.using_us_layout = false
    store_location
    params[:gift] = session[:gift_params] if session[:gift_params]
    @gift = Gift.new( gift_params )
    @ecards = ECard.find(:all, :order => :id)
    @action_js = ["dt/ecards", "dt/giving"]
    
    if params[:project_id]
      @project = Project.find(params[:project_id]) 
      @gift.project_id = @project.id if @project
      redirect_to dt_project_path(@project) and return if @project && !@project.fundable?
    end
    
    if logged_in?
      %w( email first_name last_name address city province postal_code country ).each {|f| @gift[f.to_sym] = current_user[f.to_sym] unless @gift.send("#{f}?") }
      @gift[:name] = current_user.full_name if logged_in? && !@gift.name?
      @gift[:email] = current_user.email unless @gift.email?
      
      #MP Dec 14, 2007 - In order to support US donations, this was added to switch out the
      #layout of the Gift page. If the user's country is nil or not Canada,
      #use the layout that allows for US donations.
      unless current_user.in_country?(CANADA)
        self.using_us_layout = true
        render :layout => 'us_receipt_layout'
      end
    else
      #MP Dec 14, 2007 - If there is no logged in user, we should give them the option
      #of being able to request a US tax receipt as there is no reliable way to determine
      #what country they are in.
      self.using_us_layout = true
      render :layout => 'us_receipt_layout'
    end
  end
  
  def create
    @gift = Gift.new( gift_params )    
    @gift.user_ip_addr = request.remote_ip
    @ecards = ECard.find(:all, :order => :id)
    @project = Project.find(@gift.project_id) if @gift.project_id? && @gift.project_id != 0
    @action_js = ["dt/ecards", "dt/giving"]
    
    if @gift.credit_card?
      iats = iats_payment(@gift)
      @gift.authorization_result = iats.authorization_result if iats.status == 1
    end
    @cf_investment = build_fund_cf_investment(@gift)
    @cf_deposit = build_fund_cf_deposit(@gift)
    @total_amount = @gift.amount + @cf_investment.amount if @cf_investment

    Gift.transaction do
      if @gift.credit_card? && @cf_investment && @cf_deposit
        @saved = @gift.save! && @cf_deposit.save! && @cf_investment.save! if @gift.authorization_result?
      elsif !@gift.credit_card? && @cf_investment
        @saved = @gift.save! && @cf_investment.save!
      else
        @saved = @gift.save! if !@gift.credit_card? || (@gift.credit_card && @gift.authorization_result?) 
      end
      flash.now[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact-us\">contact us</a>." if !@saved
    end

    respond_to do |format|
      if @saved
        session[:gift_params] = nil
        # send the email if it's not scheduled for later.
        @gift.send_gift_mail if @gift.send_gift_mail? == true
        # send confirmation to the gifter
        @gift.send_gift_confirm
        format.html { redirect_to :action => 'show', :id => @gift.id, :code => @gift.pickup_code }
      else
        format.html { render :action => "new" }
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
  def ssl_required?
    true
  end
  
  def send_later?
    return @send_at ? true : false
  end

  def gift_params
    gift_params = {}
    gift_params = gift_params.merge(params[:gift]) if params[:gift]
    gift_params[:user_id] = current_user.id if logged_in?
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
