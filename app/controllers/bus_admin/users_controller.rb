class BusAdmin::UsersController < ApplicationController

  active_scaffold do |config|
    
    config.label = "Donors"
    config.actions.exclude :create
    config.columns = [ :first_name, :last_name, :login, :active ]
    config.list.columns = [:first_name, :last_name, :login, :active ]
    config.update.columns = [:first_name, :last_name, :login, :display_name, :address,  :city, :province, :country, :postal_code, :active ]
    config.columns[ :active ].form_ui = :checkbox  

  end
 
end
