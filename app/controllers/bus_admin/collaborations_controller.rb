class BusAdmin::CollaborationsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold do |config|
    config.columns = [:collaborating_agency, :responsibilities, :project]
    config.columns[:collaborating_agency].form_ui = :select
    config.columns[:responsibilities].form_ui = :textarea
    config.columns[:responsibilities].options = {:rows => 10, :cols => 40}
    config.columns[:project].form_ui = :select
  end
end
