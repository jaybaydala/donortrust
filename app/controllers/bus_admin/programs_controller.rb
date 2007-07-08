class BusAdmin::ProgramsController < ApplicationController
  before_filter :login_required  
  
  active_scaffold :programs do |config|
    config.columns = [ :name, :contact, :projects_count, :projects ]
    config.columns[ :name ].label = "Program"
    config.columns[ :projects_count ].label = "Projects"
    list.columns.exclude [ :projects ]
    update.columns.exclude [ :projects, :projects_count ]
    create.columns.exclude [ :projects_count ]
    config.columns[:contact].form_ui = :select
    config.nested.add_link("Projects", [:projects])
  end
end
