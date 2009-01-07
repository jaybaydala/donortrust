class BusAdmin::CollaboratingAgenciesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold :collaborating_agencies do |config|
    config.list.columns =[ :agency_name ]
    config.columns =[ :agency_name, :description ]
  end
end
