class BusAdmin::ProgramsController < ApplicationController
  before_filter :login_required  
  
  active_scaffold :programs do |config|
    config.columns = [ :program_name, :contact, :projects, :projects_count ]
#    config.label = "Programs"
    config.columns[ :program_name ].label = "Program"
    config.columns[ :projects_count ].label = "Projects"
    list.columns.exclude [ :projects ]
    update.columns.exclude [ :projects, :projects_count ]
    create.columns.exclude [ :projects, :projects_count ]
    config.columns[:contact].ui_type = :select  
    config.columns[:projects].ui_type = :select
    config.nested.add_link("Projects", [:projects])  


#    config.label = "Contacts"
#    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
#    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
#    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
#
#    config.columns[:continent].ui_type = :select
#    config.columns[:country].ui_type = :select
#    config.columns[:region].ui_type = :select
#    config.columns[:city].ui_type = :select
  end
  
  

end
