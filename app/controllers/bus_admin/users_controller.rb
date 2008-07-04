class BusAdmin::UsersController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
   
  active_scaffold do |config|
    
  #  config.label = "Donors"
  #  config.columns = [:country, :administrated_projects]
  #  config.columns[:administrated_projects].form_ui = :select
  #  config.columns[:projects].form_ui = :select
  #  config.actions.exclude :create
    config.columns = [ :first_name, :last_name, :login, :country, :roles ]
    config.columns[:roles].form_ui = :select 
    config.list.columns = [:first_name, :last_name, :login, :roles]
    config.update.columns = [:first_name, :last_name, :login, :display_name, :address,  :city, :province, :country, :postal_code, :administrations] 

  end
 
end
