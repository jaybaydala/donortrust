class BusAdmin::RolesController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
   
  active_scaffold do |config|
    
  end
 
end
