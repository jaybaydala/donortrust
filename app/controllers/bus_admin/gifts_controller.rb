class BusAdmin::GiftsController < ApplicationController

  active_scaffold :gift do |config|
    config.list.columns = [:name,:email,:to_name,:to_email, :message, :pickup_code]
    config.show.columns = [:name,:email,:date,:comment]
    config.update.columns.exclude [ :deposit, :user_transaction, :amount, :name, :email, :to_name, :first_name, :last_name, :address, :city, :province, :postal_code, :country, :credit_card, :card_expiry, :project, :authorization_result, :pickup_code, :picked_up_at, :send_at, :sent_at, :user,  :updated_at, :e_card, :user_ip_addr]
  end
  
  def before_update_save(record)
    @record.sent_at = nil
    @record.send_at= Time.now
  end

end