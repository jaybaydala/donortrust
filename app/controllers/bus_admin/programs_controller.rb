class BusAdmin::ProgramsController < ApplicationController
  before_filter :login_required, :check_authorization 
  
  active_scaffold :programs do |config|
    config.columns = [ :name, :contact, :projects_count, :projects, :note ]
    config.columns[ :name ].label = "Program"
    config.columns[ :projects_count ].label = "Projects"
    config.columns[ :contact ].form_ui = :select
    list.columns.exclude [ :projects ]
    update.columns.exclude [ :projects, :projects_count ]
    create.columns.exclude [ :projects, :projects_count ]
    config.nested.add_link("Projects", [:projects])
  end
  
  def show_program_note   
   @note = Program.find(params[:id]).note
   render :partial => "layouts/note"   
 end
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("show_program_note")
        return permitted_action == 'show'
      else
        return false
      end  
 end
end
