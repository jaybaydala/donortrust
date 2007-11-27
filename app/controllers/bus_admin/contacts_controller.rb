class BusAdmin::ContactsController < ApplicationController
  before_filter :login_required, :check_authorization
    


  def index
    @page_title = 'Contacts'
    @contacts = Contact.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
#  def new
#
#  end
#  
  def show
    begin
      @contact = Contact.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @contact.fullname
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Contact Details"
    @contact = Contact.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @contact = Contact.find(params[:id])
  @saved = @contact.update_attributes(params[:contact])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Contact was successfully updated.'
        format.html { redirect_to contact_path(@contact) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors.to_xml }
      end
    end
  end
  
  def create
    @contact = Contact.new(params[:contact])
    Contact.transaction do
      @saved= @contact.valid? && @contact.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to contacts_url }
        flash[:notice] = 'Contact was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end

  def populate_contact_places
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
    
    render :partial => "bus_admin/contacts/place_form"
  end
  
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("populate_contact_places")
        return permitted_action == 'edit' || permitted_action == 'create'
      else
        return false
      end  
  end

end
