class BusAdmin::LoadsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 

   active_scaffold :loads do |config|
    config.columns = [:name, :email, :sent, :invitation]  
 end
   
end

