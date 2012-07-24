class BusAdmin::OrdersController < ApplicationController
  layout 'admin'
  
  active_scaffold :order do |config|
    config.list.sorting = { :id => :desc }
    config.columns = [ :donor_type, :title, :first_name, :last_name, :company, :email, :address, :address2, :city, :province, :country, :postal_code, :total, 
      :account_balance_payment, :credit_card_payment, :gift_card_payment, :pledge_account_payment, :authorization_result, :order_number, :user_id, :complete,
      :tax_receipt_requested, :offline_fund_payment, :notes, :cart, :user, :order, :view_code, :amount ]
    config.list.columns = [ :id, :first_name, :last_name, :email, :total, :created_at ]
    
  end
end
