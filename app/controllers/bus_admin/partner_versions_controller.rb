class BusAdmin::PartnerVersionsController < ApplicationController

  active_scaffold do |config|
    config.actions = [:list, :show, :nested]
    
    config.action_links.add 'list', :label => 'Back', :parameters => {:controller => 'partners', }, :page => true
  end

end
