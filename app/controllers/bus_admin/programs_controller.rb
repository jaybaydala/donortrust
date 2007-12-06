class BusAdmin::ProgramsController < ApplicationController
 # before_filter :login_required, :check_authorization 
  
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
    @programs = Program.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def show
    begin
      @program = Program.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
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
  
  def edit     
    @page_title = "Edit Program Details"
    @program = Program.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def create
    @program = Program.new(params[:program])    
    @program.contact_id = params[:contact_id] if params[:contact_id]  
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
  
  def update    
  @program = Program.find(params[:id])
  @saved = @program.update_attributes(params[:program])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Program was successfully updated.'
        format.html { redirect_to bus_admin_program_path(@program) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program.errors.to_xml }
      end
    end
  end
  

end
