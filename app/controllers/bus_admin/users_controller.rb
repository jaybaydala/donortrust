class BusAdmin::UsersController < ApplicationController
  before_filter :login_required #, :check_authorization
   
  active_scaffold do |config|
    
    config.label = "Donors"
    config.actions.exclude :create
    config.columns = [ :first_name, :last_name, :login ]
    config.list.columns = [:first_name, :last_name, :login]
    config.update.columns = [:first_name, :last_name, :login, :display_name, :address,  :city, :province, :country, :postal_code] 

  end
 
end
