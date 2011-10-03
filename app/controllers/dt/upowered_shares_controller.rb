class Dt::UpoweredSharesController < DtApplicationController
  def create
    @upowered_share = UpoweredShare.new(params[:upowered_share].merge({ :upowered_url => dt_upowered_url }))
    if @upowered_share.valid?
      @upowered_share.send_messages
      flash[:notice] = "Thanks for sharing U:Powered! Your messages have been sent"
      redirect_to params[:return_to].present? ? params[:return_to] : iend_user_path(:current)
    else
      render :action => "new"
    end
  end
end