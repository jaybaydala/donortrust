class BusAdmin::LoadsController < ApplicationController

   active_scaffold :loads do |config|
    config.columns = [:name, :email, :sent, :invitation]  
 end
   
end

