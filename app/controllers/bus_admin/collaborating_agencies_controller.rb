class BusAdmin::CollaboratingAgenciesController < ApplicationController
  layout :choose_layout
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold :collaborating_agencies do |config|
    config.list.columns =[ :agency_name ]
    config.columns =[ :agency_name, :description ]
  end

  private
  def choose_layout    
    if params['page_format'] == 'admin_popup' 
      'admin_popup'
    else
      'admin'
    end
  end
end
