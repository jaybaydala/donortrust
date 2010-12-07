class Dt::DonationsController < DtApplicationController
  include OrderHelper
  before_filter :find_cart
  before_filter :load_donation

  def edit
    logger.debug @donation.inspect
    respond_to do |format|
      format.html {
        redirect_to dt_cart_path and return unless @donation
        if request.xhr?
          render :action => "edit", :layout => false
        else
          render :action => "edit"
        end
      }
    end
  end
  
  def update
    if params[:cart_line_item][:percentage] == ""
      params[:cart_line_item][:auto_calculate_amount] = false
    else
      params[:cart_line_item][:auto_calculate_amount] = true
    end
    @saved = @donation.update_attributes(params[:cart_line_item])
    
    redirect_to dt_cart_path
  end
  
  def destroy
  end
  
  private
    def load_donation
      if @cart.donation && @cart.donation.item.kind_of?(Investment)
        @donation = @cart.donation
        @donation.amount = @donation.item.amount
        @project = @donation.item.project if @donation.item.project_id?
      end
    end
end