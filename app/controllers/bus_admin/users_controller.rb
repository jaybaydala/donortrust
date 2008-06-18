class BusAdmin::UsersController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
   
  active_scaffold do |config|
    
    config.label = "Donors"
    config.actions.exclude :create
    config.columns = [ :first_name, :last_name, :login ]
    config.list.columns = [:first_name, :last_name, :login]
    config.update.columns = [:first_name, :last_name, :login, :display_name, :address,  :city, :province, :country, :postal_code] 

  end
 
end
