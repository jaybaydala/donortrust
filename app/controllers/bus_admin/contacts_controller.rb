class BusAdmin::ContactsController < ApplicationController
  #before_filter :login_required
  
  active_scaffold :contact do |config|    
    config.label = "Contacts"
    config.list.columns = [:first_name, :last_name, :phone_number, :email_address]
    config.update.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
    config.create.columns = [:first_name, :last_name, :phone_number, :fax_number, :email_address, :web_address, :department, :continent, :country, :region, :urban_centre, :address_line_1, :address_line_2, :postal_code]
    config.show.columns = [:first_name, :last_name, :urban_centre]
    
    config.columns[:continent].ui_type = :select
    config.columns[:country].ui_type = :select
    config.columns[:region].ui_type = :select
    config.columns[:urban_centre].ui_type = :select
  end

  def populate_contact_countries
    countries = Country.find :all, :conditions => ["continent_id = ?", params[:record_continent]]
    #id="record_urban_centre" class="urban_centre-input" name="record[urban_centre][id]"
    result = "<select id='record_country' class='country-input' name='record[country][id]'> "
    for country in countries
      result += "<option value=" + country.id.to_s + ">" + country.name.to_s + "</option>"
    end
    result += "</select>"
    puts result
    render :text => result
  end
  
  def populate_contact_regions
  
    regions = Region.find :all, :conditions => ["country_id = ?", params[:record_country]]
    #id="record_urban_centre" class="urban_centre-input" name="record[urban_centre][id]"
    result = "<select id='record_region' class='region-input' name='record[region][id]'> "
    for region in regions
      result += "<option value=" + region.id.to_s + ">" + region.name.to_s + "</option>"
    end
    result += "</select>"
    puts result
    render :text => result
  end
  
  def populate_contact_urban_centres
  
  end
end
