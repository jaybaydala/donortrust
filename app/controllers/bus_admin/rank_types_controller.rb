class BusAdmin::RankTypesController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :rank_types do |config|
    config.columns = [ :name, :description ]    
 end
end



