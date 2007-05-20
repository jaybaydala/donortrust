class ContactsController < ApplicationController
  active_scaffold :contact do |config|
    
    config.label = "Contacts"
    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :city, :address_line_1, :address_line_2, :postal_code]
    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :city, :address_line_1, :address_line_2, :postal_code]

    config.columns[:continent].ui_type = :select
    config.columns[:country].ui_type = :select
    config.columns[:region].ui_type = :select
    config.columns[:city].ui_type = :select
  end
  
#   active_scaffold :company do |config|
#    config.label = "Customers"
#    config.columns = [:name, :phone, :company_type, :comments]
#    list.columns.exclude :comments
#    list.sorting = {:name => 'ASC'}
#    columns[:phone].label = "Phone #"
#    columns[:phone].description = "(Format: ###-###-####)"
#  end

#      t.column :first_name, :string, :null => false
#      t.column :last_name, :string, :null => false
#      t.column :phone_number, :string
#      t.column :fax_number, :string
#      t.column :email_address, :string
#      t.column :web_address, :string
#      t.column :department, :string
#      t.column :continent_id, :integer#, :null => false
#      t.column :country_id, :integer
#      t.column :region_id, :integer#, :null => false
#      t.column :city_id, :integer#, :null => false
#      t.column :address_line_1, :string
#      t.column :address_line_2, :string
#      t.column :postal_code, :string

end
