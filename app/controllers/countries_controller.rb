class CountriesController < ApplicationController
 before_filter :get_data
  active_scaffold :countries do |config|     
     config.columns = [:id, :country_name]
     
config.create.columns.exclude :id
     config.update.columns.exclude :id
         config.list.columns.exclude :id
#config.subform.columns = [:first_name, :last_name, :login, :password]     
config.list.sorting = {:country_name => 'ASC'}     
config.nested.add_link "Countries", [:countries]     
config.create.columns.exclude(:id)     
#config.create.columns.add_subgroup "Optional" do |group|       
#group.add(:first_name, :middle_name, :last_name, :phone_number)     
#end   

end


 def get_data
    @continents = Continent.find(:all)

  end
end  