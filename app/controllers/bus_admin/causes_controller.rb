class BusAdmin::CausesController < ApplicationController
  before_filter :login_required#, :check_authorization

  include ApplicationHelper

  active_scaffold :causes do |config|
    config.columns =[ :name, :description, :sector, :projects_count, :projects ]
    list.columns.exclude [ :projects_count, :projects ]
#    show.columns.exclude [ ]
    update.columns.exclude [ :projects_count, :projects ]
    create.columns.exclude [ :projects_count, :projects ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    config.columns[ :sector ].form_ui = :select
    config.columns[ :name ].label = "Cause"
  end

  def get_model
    return Cause
  end
end
