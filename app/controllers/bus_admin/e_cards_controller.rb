class BusAdmin::ECardsController < ApplicationController

 before_filter :login_required#, :check_authorization
  
  active_scaffold :e_cards do |config|
    config.columns =[ :name, :file, :credit ]
    config.columns[ :file ].label = "Image File"
    config.create.multipart = true
    config.update.multipart = true
  
  end
  
end