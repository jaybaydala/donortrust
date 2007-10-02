class BusAdmin::CollaboratingAgenciesController < ApplicationController

  before_filter :login_required#, :check_authorization
  
  active_scaffold :collaborating_agencies do |config|
    config.columns =[ :agency_name, :responsibilities, :project ]
    config.columns[ :project ].form_ui = :select  
  end  
end
