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