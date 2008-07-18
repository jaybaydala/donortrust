class BusAdmin::ContactsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
    
  active_scaffold :contact do |config|    
    config.label = "Contacts"
    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :place, :address_line_1, :address_line_2, :postal_code]
    #config.nested.columns = [:first_name, :last_name, :phone_number]
    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :place, :address_line_1, :address_line_2, :postal_code]
    config.show.columns = [:first_name, :last_name, :place]
    
    config.columns[:place].form_ui = :select
        
    config.subform.columns.exclude :fax_number,:web_address, :department, :place, :address_line_1, :address_line_2, :postal_code
    
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
