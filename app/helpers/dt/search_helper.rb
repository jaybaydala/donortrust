module Dt::SearchHelper
  def dt_search_bar
    render 'dt/search/bar', :layout => false
  end

  def dt_search_by_place_select
    @places = [['Make a Difference in...', '']]
    Project.continents_and_countries.each do |place|
      name = place.parent_id? ? "- #{place.name}" : place.name
      @places << [name, place.id]
    end
    select_tag("place_id", options_for_select(@places)) if @places
  end
  
  def dt_search_by_cause_select
    @causes = [['I Want To Help With...', '']]
    Project.causes.each do |cause|
      @causes << [cause.name, cause.id]
    end
    select_tag("cause_id", options_for_select(@causes)) if @causes
  end
  
  def dt_search_by_organization_select
    @partners = [['Partner With...', '']]
    Project.partners.each do |partner|
      @partners << [partner.name, partner.id]
    end
    select_tag("partner_id", options_for_select(@partners)) if @partners
  end
end
