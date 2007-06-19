class BusAdmin::ContactsController < ApplicationController
  before_filter :login_required

  active_scaffold :contact do |config|    
    config.label = "Contacts"
    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
    config.show.columns = [:first_name, :last_name, :urban_centre]
    
    config.columns[:continent].ui_type = :select
    config.columns[:country].ui_type = :select
    config.columns[:region].ui_type = :select
    config.columns[:urban_centre].ui_type = :select
  end

end
