class Dt::UpoweredEmailSubscribesController < DtApplicationController
  def create
    @upowered_email_subscribe = UpoweredEmailSubscribe.new(params[:upowered_email_subscribe])
    @saved = @upowered_email_subscribe.save
    flash[:notice] = @saved ? "You have been signed up" : "Please include a valid email address to signup"
    redirect_to dt_upowered_path
  end
  
  def unsubscribe
    @upowered_email_subscribe = UpoweredEmailSubscribe.find_by_code(params[:id])
    if @upowered_email_subscribe
      @upowered_email_subscribe.destroy 
      flash[:notice] = "You have been unsubscribed"
    else
      flash[:notice] = "We couldn't find a matching record to unsubscribe. Please try again."
    end
    redirect_to dt_upowered_path
  end
end