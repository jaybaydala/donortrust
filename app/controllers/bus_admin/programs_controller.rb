class BusAdmin::ProgramsController < ApplicationController
  
  active_scaffold :programs do |config|
    config.label = "Programs"
    config.columns = [:program_name, :contact]
    config.create.columns = [:program_name, :contact, :title]    
    #config.columns[:contact].ui_type = :select
    

    
#    config.label = "Contacts"
#    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
#    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :city, :address_line_1, :address_line_2, :postal_code]
#    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :city, :address_line_1, :address_line_2, :postal_code]
#
#    config.columns[:continent].ui_type = :select
#    config.columns[:country].ui_type = :select
#    config.columns[:region].ui_type = :select
#    config.columns[:city].ui_type = :select
  end
  
  

end
