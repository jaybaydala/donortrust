class BusAdmin::ProjectPoisController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  
  active_scaffold :project_pois do |config|
    config.columns = [ :project, :user, :name, :email, :send_updates, :gift_giver, :gift_receiver, :investor ]
    config.columns[ :project ].form_ui = :select
    config.columns[ :user ].form_ui = :select
  end
end 
  
