class BusAdmin::LoadsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin' 

   active_scaffold :loads do |config|
    config.columns = [:name, :email, :sent, :invitation]  
 end
   
end

