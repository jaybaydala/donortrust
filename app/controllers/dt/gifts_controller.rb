require 'iats/iats_process.rb'
class Dt::GiftsController < DtApplicationController
  include IatsProcess
  before_filter :login_required, :only => :unwrap
  
  def new
    @gift = Gift.new
    if logged_in?
      user = User.find(current_user.id)
      %w( email first_name last_name address city province postal_code country ).each {|f| @gift[f.to_sym] = current_user[f.to_sym] }
      @gift[:name] = current_user.full_name if logged_in?
      @gift[:email] = current_user.email
    end
  end

  def create
    @gift = Gift.new( gift_params )
    if params[:gift][:credit_card]
      iats = iats_payment(@gift)
      @gift.authorization_result = iats.authorization_result if iats.status == 1
    end
    respond_to do |format|
      if @gift.save
        format.html
      else
        format.html { render :action => "new" }
      end
    end
  end

  def confirm
    @gift = Gift.new( gift_params )
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
      flash[:error] = 'The provided pickup code is not valid. Please check your email and try again.' if params[:code] && !@gift
      format.html
    end
  end
  
  def unwrap
    @gift = Gift.validate_pickup(params[:gift][:pickup_code], params[:id])
    redirect_to :action => 'open' and return if !@gift
    @gift.pickup
    respond_to do |format|
      if @gift.picked_up?
        Deposit.create_from_gift(@gift, current_user.id)
        format.html { redirect_to :controller => 'dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash[:error] = 'Your gift couldn\'t be picked up at this time. Please recheck your code and try again.'
        format.html { redirect_to :action => 'open' }
      end
    end
  end

  protected
  def gift_params
    card_exp = "#{params[:gift][:expiry_month]}/#{params[:gift][:expiry_year]}" if params[:gift][:expiry_month] != nil && params[:gift][:expiry_year] != nil
    gift_params = params[:gift]
    gift_params.delete :expiry_month
    gift_params.delete :expiry_year
    gift_params[:card_expiry] = card_exp if gift_params[:card_expiry] == nil
    gift_params[:user_id] = current_user.id if logged_in?
    gift_params
  end
end
