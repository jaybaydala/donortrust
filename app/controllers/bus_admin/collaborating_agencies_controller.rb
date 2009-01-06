class BusAdmin::CollaboratingAgenciesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold :collaborating_agencies do |config|
    config.list.columns =[ :agency_name, :approved ]
    config.columns =[ :agency_name, :approved, :description ]
    config.columns[ :approved ].form_ui = :checkbox
  end
end
