class BusAdmin::PartnerVersionsController < ApplicationController
  before_filter :login_required, :check_authorization
  active_scaffold do |config|
    config.actions = [:list, :show, :nested]
    
    config.action_links.add 'list', :label => 'Back', :parameters => {:controller => 'partners', }, :page => true
  end

end
