class BusAdmin::ProgramsController < ApplicationController
  before_filter :login_required, :check_authorization 
  
#  active_scaffold :programs do |config|
#    config.columns = [ :name, :contact, :projects_count, :projects, :note ]
#    list.columns.exclude [ :projects ]
#    #show.columns.exclude [ ]
#    update.columns.exclude [ :projects, :projects_count ]
#    create.columns.exclude [ :projects, :projects_count ]
#    config.columns[ :name ].label = "Program"
#    config.columns[ :projects_count ].label = "Projects"
#    config.columns[ :contact ].form_ui = :select
#    config.columns[ :rss_feed ].form_ui = :select
#    config.nested.add_link("Projects", [:projects])
#  end
  
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

  def index
    @page_title = 'Programs'
    @programs = Program.find(:all)#, :conditions => { :featured => 1 })
#    @projects = Project.find_public(:all, :limit => 3) if @projects.size == 0
    respond_to do |format|
      format.html
    end
  end
  
  def show
    begin
      @program = Program.find(params[:id])
    rescue ActiveRecord::RecordNotFound
#      rescue_404 and return
    end
    @page_title = @program.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @program = Program.find(params[:id])
    @program.destroy
    respond_to do |format|
      format.html { redirect_to bus_admin_programs_url }
      format.xml  { head :ok }
    end
  end
  
  def create
    @program = Program.new(params[:programs])
    Program.transaction do
      @saved= @program.valid? && @program.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_programs_url }
        flash[:notice] = 'Program was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  

end
