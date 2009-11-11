class BusAdmin::UpoweredController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  def show
  end
  
  def report
  end
  
  def send_email
    @upowered_email_subscribes = UpoweredEmailSubscribe.all
    @upowered_email_subscribes.each do |email_subscription|
      DonortrustMailer.deliver_upowered_email_subscription(email_subscription)
    end
    flash[:notice] = "#{@upowered_email_subscribes.size} emails sent"
    redirect_to bus_admin_upowered_path
  end
end