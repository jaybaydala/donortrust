class BusAdmin::RssFeedElementsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 


  active_scaffold

end
