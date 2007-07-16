class BusAdmin::ProgramsController < ApplicationController
  before_filter :login_required  
  
  active_scaffold :programs do |config|
    config.columns = [ :name, :contact, :projects_count, :projects, :note ]
    config.columns[ :name ].label = "Program"
    config.columns[ :projects_count ].label = "Projects"
    list.columns.exclude [ :projects ]
    update.columns.exclude [ :projects, :projects_count ]
    create.columns.exclude [ :projects_count ]
    config.columns[:contact].form_ui = :select
    config.nested.add_link("Projects", [:projects])
  end
  
  def show_program_note   
   @note = Program.find(params[:id]).note
   render :partial => "layouts/note"   
  end
end
