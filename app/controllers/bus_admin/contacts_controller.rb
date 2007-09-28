class BusAdmin::ContactsController < ApplicationController
  before_filter :login_required, :check_authorization
    
  active_scaffold :contact do |config|    
    config.label = "Contacts"
    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :place, :address_line_1, :address_line_2, :postal_code]
    #config.nested.columns = [:first_name, :last_name, :phone_number]
    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :place, :address_line_1, :address_line_2, :postal_code]
    config.show.columns = [:first_name, :last_name, :place]
    
    config.columns[:place].form_ui = :select
        
    config.subform.columns.exclude :fax_number,:web_address, :department, :place, :address_line_1, :address_line_2, :postal_code
    
  end

end
