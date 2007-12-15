class BusAdmin::RankTypesController < ApplicationController
  before_filter :login_required, :check_authorization
  
  active_scaffold :rank_types do |config|
    config.columns = [ :name, :description ]    
 end
end



