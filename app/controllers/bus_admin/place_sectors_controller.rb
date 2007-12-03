class BusAdmin::PlaceSectorsController < ApplicationController
  before_filter :login_required, :check_authorization
  
  def index
    @page_title = 'Place Sectors'
    @sectors = PlaceSector.find(:all)
    respond_to do |format|
      format.html
    end 
  end

   def show
    begin
      @sector = PlaceSector.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = 'Place Sectors'
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @sector = PlaceSector.find(params[:id])
    @sector.destroy
    respond_to do |format|
      format.html { redirect_to place_sectors_url }
      format.xml  { head :ok }
    end
  end
  
#  def edit     
#    @page_title = "Edit Project Status Details"
#    @project = ProjectStatus.find(params[:id])
#    respond_to do |format|
#      format.html
#    end    
#  end
  
  def update
    
  @sector = @sector.find(params[:id])
  @saved = @project.update_attributes(params[:sector])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Place Sector was successfully updated.'
          
        format.html { redirect_to place_sectors_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sector.errors.to_xml }
      end
    end
  end
  
  def create
    @sector = PlaceSector.new(params[:sector])
    Contact.transaction do
      @saved= @sector.valid? && @sector.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to place_sectors_url }
        flash[:notice] = 'Place Sector was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def populate_place_sector_places
    @filterMessage = ""
    @places = nil
    @selectedPlace = nil
    @parentString = ""
    @boolShowTop = true
    
    if params[:record_place] != nil and params[:record_place] != ""
      @selectedPlace = Place.find(params[:record_place])
    end

    if params[:posttype] == "top"
        #Get all records with parent_id == null
        @boolShowTop = false
        @places = Place.find :all, :conditions => ["parent_id is null"]        
    else
      if params[:posttype] == "down"
        if params[:record_place] == nil or params[:record_place] == ""
          #if selected record was "please select a Place"
          @boolShowTop = false
          @places = Place.find :all, :conditions => ["parent_id is null"]
        else
          #selected record is a proper value
          @boolShowTop = true
          @parentString = Place.getParentString(@selectedPlace)
          @places = Place.find :all, :conditions => ["parent_id = ?", @selectedPlace.id]
        end
        
        #if the selected record had no children, reload with selected / peers and update message
        if @places.length == 0
          @places = Place.find :all, :conditions => ["parent_id = ?", @selectedPlace.parent_id]
          @filterMessage = @selectedPlace.name + " has no children."
        end
      end
    end
    
    render :partial => "bus_admin/place_sectors/place_form"
  end
  
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("populate_place_sectors_places")
        return permitted_action == 'edit' || permitted_action == 'create'
      else
        return false
      end  
  end

end


