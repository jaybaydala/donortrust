class BusAdmin::LoadsController < ApplicationController
   before_filter :login_required, :check_authorization 
   active_scaffold :loads do |config|
    config.columns = [:name, :email, :sent, :invitation]  
 end
   
end

