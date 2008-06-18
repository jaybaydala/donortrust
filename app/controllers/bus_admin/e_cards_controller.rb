class BusAdmin::ECardsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :e_cards do |config|
    config.create.multipart = true
    config.update.multipart = true
    config.columns =[ :name, :small, :medium, :large, :printable, :credit ]
    config.list.columns = [:name] 
    config.columns[:small].label = "Small Image"
    config.columns[:medium].label = "Medium Image"
    config.columns[:large].label = "Large Image"
    config.columns[:printable].label = "Printable Image"
  end
end