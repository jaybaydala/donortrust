require 'order_helper'
class Dt::BulkGiftsController < DtApplicationController
  helper "dt/places"
  include OrderHelper
  before_filter :login_required, :only => :unwrap
  
  def index
    respond_to  do |format|
      format.html {redirect_to :action => 'new'}
    end
  end
  
  def new
    store_location
    find_cart
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
    end
  end
  
  def create
    @gifts = []
    @errors = []
    params[:recipients].split(',').each do |r|
      r = r.strip
      # email = EmailParser.new(r)
      gift = Gift.new( gift_params )
      gift.to_email = r
      gift.to_email_confirmation = r
      gift.user_ip_addr = request.remote_ip
      set_send_now_delivery!(gift)
      @errors << gift unless gift.valid?
      @gifts << gift
    end
    

    respond_to do |format|
      if @errors.empty?
        find_cart
        @gifts.each{|gift| @cart.add_item(gift)}
        flash[:notice] = "Your Gifts have been added to your cart."
        format.html { redirect_to dt_cart_path }
      else
        @project = @gift.project if @gift.project_id? && @gift.project
        @ecards = ECard.find(:all, :order => :id)
        format.html { render :action => "new" }
      end
    end
  end

  protected
  def set_send_now_delivery!(gift)
    if params[:gift] && params[:gift][:send_email] && params[:gift][:send_email] == "now"
      gift.send_email = true
      gift.send_at = Time.now + 5.minutes
    end
  end
  
  def gift_params
    gift_params = {}
    gift_params = gift_params.merge(params[:gift]) if params[:gift]
    gift_params[:user] = current_user if logged_in?
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
  
end