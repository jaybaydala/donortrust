require 'pdf_proxy'
include PDFProxy

class BusAdmin::GiftsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold :gift do |config|
    config.list.columns = [:name,:email,:to_name,:to_email, :message, :pickup_code]
    config.show.columns = [:name,:email,:date,:comment]
    config.update.columns.exclude [ :deposit, :user_transaction, :amount, :name, :email, :to_name, :first_name, :last_name, :address, :city, :province, :postal_code, :country, :credit_card, :card_expiry, :project, :authorization_result, :pickup_code, :picked_up_at, :send_at, :sent_at, :user,  :updated_at, :e_card, :user_ip_addr]

   config.action_links.add 'list', :label => 'Resend to Both', :parameters =>{:controller=>'gifts', :action => 'resend'},:page => true, :type=> :record
   config.action_links.add 'list', :label => 'Resend Gift', :parameters =>{:controller=>'gifts', :action => 'resend_gift'},:page => true, :type=> :record
   config.action_links.add 'list', :label => 'Resend to Sender', :parameters =>{:controller=>'gifts', :action => 'resend_sender'}, :page => true, :type=> :record
  end

  def before_update_save(record)
    @record.sent_at = nil
    @record.send_at= Time.now
  end

 def resend
    @gift = Gift.find(params[:id])
    @gift.send_gift_resend
    flash[:notice] = "Resent Email."   
    
    respond_to do |format|
      format.html { redirect_back_or_default(:controller => '/bus_admin/gifts', :action => 'index') }
    end
  end
  
  def resend_gift
   @gift = Gift.find(params[:id])
   if @gift.valid?
     @gift.send_gift_mail
     flash[:notice] = "Gift was emailed successfully."
   else        
     flash[:notice] = "Problems with resend, gift not sent" 
   end      
    respond_to do |format|
      format.html { redirect_back_or_default(:controller => '/bus_admin/gifts', :action => 'index') }
    end
 end

  def resend_sender
    @gift = Gift.find(params[:id])
    if @gift.valid?
      @gift.send_gift_resend_sender
      flash[:notice] = "Gift was emailed successfully."
    else
      flash[:notice] = "Problems with resend, gift not sent"
    end
    respond_to do |format|
      format.html { redirect_back_or_default(:controller => '/bus_admin/gifts', :action => 'index') }
    end
  end

end