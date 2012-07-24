class BusAdmin::TaxReceiptsController < ApplicationController
  layout 'admin'
  
  active_scaffold :tax_receipt do |config|
    config.list.sorting = { :id => :desc }
    config.columns = [ :first_name, :last_name, :email, :address, :city, :province, :country, :view_code, :amount ]
    config.list.columns = [ :id, :first_name, :last_name, :email, :total, :created_at ]
  end
end
