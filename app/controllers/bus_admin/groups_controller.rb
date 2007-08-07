class BusAdmin::GroupsController < ApplicationController
before_filter :login_required, :check_authorization
  active_scaffold :groups do |config|
    config.columns = [:name, :description, :projects, :public ]
    config.actions.exclude :nested #:add_existing #this doesn't appear to work though the problem is now avoided by not allowing nested in Projects; what was when this was appearing
    config.columns[:projects].form_ui = :select
  end

end
