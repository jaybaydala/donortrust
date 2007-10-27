require 'iats/iats_process.rb'
require 'pdf_proxy'
include PDFProxy

class Dt::GiftsController < DtApplicationController
  helper "dt/places"
  include IatsProcess
  before_filter :login_required, :only => :unwrap
  
  def index
    respond_to do |format|
      format.html { redirect_to :action => 'new' }
    end
  end

  def show
    @gift = Gift.find(params[:id])
    respond_to do |format|
      format.pdf {
        if not @gift[:pickup_code]
          flash[:notice] = "The gift has already been picked up so the printable card is no longer available."
          redirect_to :action => 'new'
        else
          proxy = create_pdf_proxy(@gift)
          send_data proxy.render, :filename => proxy.filename, :type => "application/pdf"
        end
      }
    end
  end
  
  def new
    store_location
    @gift = Gift.new
    @ecards = ECard.find(:all, :order => :id)
    @action_js = "dt/ecards"
    if params[:project_id]
      @project = Project.find(params[:project_id]) 
      @gift.project_id = @project.id if @project
    end
    if logged_in?
      user = User.find(current_user.id)
      %w( email first_name last_name address city province postal_code country ).each {|f| @gift[f.to_sym] = current_user[f.to_sym] }
      @gift[:name] = current_user.full_name if logged_in?
      @gift[:email] = current_user.email
    end  
  end
  
  def create
    @gift = Gift.new( gift_params )    
    @gift.user_ip_addr = request.remote_ip
    @tax_receipt = TaxReceipt.new( params[:tax_receipt] )
    
    if params[:gift][:credit_card] && params[:gift][:credit_card] != ''
      iats = iats_payment(@gift)
      @gift.authorization_result = iats.authorization_result if iats.status == 1
      @saved = @gift.save if @gift.authorization_result != nil
      flash.now[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact.htm\">contact us</a>." if !@saved
    else
      @saved = @gift.save
    end
    respond_to do |format|
      if @saved               
        if params[:gift][:credit_card] && params[:gift][:credit_card] != '' && @gift.country == 'Canada' 
          get_receipt
        end  #could do 1 ugly if
        if @tax_receipt.country == 'Canada' or @tax_receipt.country == 'Canada' and  !logged_in?
          get_receipt
        end
        # send the email if it's not scheduled for later.
        @gift.send_gift_mail if @gift.send_gift_mail? == true
        # send confirmation to the gifter
        @gift.send_gift_confirm
        format.html
      else
        format.html { render :action => "new" }
      end
    end
  end

  def confirm
    @gift = Gift.new( gift_params )
    @ecards = ECard.find(:all, :order => :id)
    @project = Project.find(@gift.project_id) if @gift.project_id? && @gift.project_id != 0
    @action_js = "dt/ecards"
    schedule(@gift)
    respond_to do |format|
      if @gift.valid?
        format.html { render :action => "confirm" }
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
        logger.info "STARTING UNWRAP TRANSACTION"
        Gift.transaction do
          logger.info "CREATING DEPOSIT"
          @deposit = Deposit.new_from_gift(@gift, current_user.id)
          @deposit.user_ip_addr = request.remote_ip
          @deposit.save!
          logger.info "CREATING INVESTMENT"
          @investment = Investment.new_from_gift(@gift, current_user.id) if @gift.project_id
          @investment.user_ip_addr = request.remote_ip if @investment
          @investment.save! if @investment
        end
        logger.info "FINISHING UNWRAP TRANSACTION"
        format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash[:error] = 'Your gift couldn\'t be picked up at this time. Please recheck your code and try again.'
        format.html { redirect_to :action => 'open' }
      end
    end
  end

  def preview
    @gift = Gift.new( gift_params )
    
    # there are a couple of necessary field just for previewing
    valid = true
    %w( email to_email ).each do |field|
      valid = false if !@gift.send(field + '?')
    end
    logger.info "valid? #{valid}"
    if valid
      @gift.pickup_code = '[pickup code]'
      @gift_mail = DonortrustMailer.create_gift_mail(@gift)
      logger.info "gift mail: #{@gift_mail.class}"
    end
    respond_to do |format|
      flash.now[:error] = 'To preview your ecard, please provide your email and the recipient\'s email' if !valid
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
    card_exp = "#{params[:gift][:expiry_month]}/#{params[:gift][:expiry_year]}" if params[:gift][:expiry_month] != nil && params[:gift][:expiry_year] != nil
    gift_params = params[:gift]
    gift_params.delete :expiry_month
    gift_params.delete :expiry_year
    gift_params[:card_expiry] = card_exp if gift_params[:card_expiry] == nil
    gift_params[:user_id] = current_user.id if logged_in?
    normalize_send_at!(gift_params)
    gift_params
  end
  
  def get_receipt
    if logged_in?
      @tax_receipt.user = current_user
    end
    @tax_receipt.gift_id = @gift.id
    @tax_receipt.email = @gift.email
    @tax_receipt.first_name = @gift.first_name
    @tax_receipt.last_name = @gift.last_name
    @tax_receipt.address = @gift.address
    @tax_receipt.city = @gift.city
    @tax_receipt.province = @gift.province
    @tax_receipt.postal_code = @gift.postal_code
    @tax_receipt.country = @gift.country
    @tax_receipt.save
    @tax_receipt.send_tax_receipt   
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
