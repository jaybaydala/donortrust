class BusAdmin::ContactsController < ApplicationController
  before_filter :login_required, :check_authorization
  
  
  active_scaffold :contact do |config|    
    config.label = "Contacts"
    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
    #config.nested.columns = [:first_name, :last_name, :phone_number]
    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
    config.show.columns = [:first_name, :last_name, :urban_centre]
    
    config.columns[:continent].form_ui = :select
    config.columns[:country].form_ui = :select
    config.columns[:region].form_ui = :select
    config.columns[:urban_centre].form_ui = :select
    
    
    config.subform.columns.exclude :fax_number,:web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code
    
  end



  def populate_contact_countries
    if params[:record_continent] != "" and params[:record_continent] != "null"  
      countries = Country.find :all, :conditions => ["continent_id = ?", params[:record_continent]]
      @result = "<select id='record_country' class='country-input' name='record[country][id]'> "
      @result += "<option value=''>-- Select Country --</option>"    
      for country in countries
        @result += "<option value=" + country.id.to_s + ">" + country.name.to_s + "</option>"
      end
      @result += "</select>"
    else
      @result = "<select id='record_country' class='country-input' name='record[country][id]'><option value=''></option></select>"
    end  
    #puts @result    
    render :partial => "bus_admin/contacts/country_form"   
  end
  
  def populate_contact_regions
    if params[:record_country] != "" and params[:record_country] != "null"
      regions = Region.find :all, :conditions => ["country_id = ?", params[:record_country]]
      @result = "<select id='record_region' class='region-input' name='record[region][id]'> "
      @result += "<option value=''>-- Select Region --</option>"
      for region in regions
        @result += "<option value=" + region.id.to_s + ">" + region.region_name.to_s + "</option>"
      end
      @result += "</select>"
    else
      @result = "<select id='record_region' class='region-input' name='record[region][id]'><option value=''></option></select>"
    end
    puts @result
    render :partial => "bus_admin/contacts/region_form"
  end
  
  def populate_contact_urban_centres
    if params[:record_region] != "" and params[:record_region] != "null"
      urbanCentres = UrbanCentre.find :all, :conditions => ["region_id = ?", params[:record_region]]
      @result = "<select id='record_urban_centre' class='urban-centre-input' name='record[urban_centre][id]'> "
      @result += "<option value=''>-- Select Urban Centre --</option>"
      for urbanCentre in urbanCentres
        @result += "<option value=" + urbanCentre.id.to_s + ">" + urbanCentre.name.to_s + "</option>"
      end
      @result += "</select>"
    else
      @result = "<select id='record_urban_centre' class='urban-centre-input' name='record[urban_centre][id]'><option value=''></option></select>"
    end
    puts @result
    render :partial => "bus_admin/contacts/urban_centre_form"
  end

  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("populate_contact_countries" || "populate_contact_regions" || "populate_contact_urban_centres")
        return permitted_action == 'edit' || permitted_action == 'create'
      else
        return false
      end  
 end


end
