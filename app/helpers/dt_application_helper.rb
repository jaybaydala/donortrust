module DtApplicationHelper
  
  def dt_head
    render 'dt/shared/head'
  end

  def dt_nav
    render 'dt/shared/nav'
  end

  def dt_masthead_image
    @image = '/images/dt/feature_graphics/feelGreat155.jpg'
  end
  
  def dt_search_by_place_select
    @places = [['Choose a Place', '']]
    Place.find(Project.places, :order => "parent_id, name").each do |place|
      name = place.parent_id? ? "- #{place.name}" : place.name
      @places << [name, place.id]
    end
    select_tag("place_id", options_for_select(@places)) if @places
  end
  
  def dt_search_by_cause_select
    @causes = [['Choose a Cause', '']]
    Project.causes do |cause|
      @causes << [cause.name, cause.id]
    end
    select_tag("cause_id", options_for_select(@causes)) if @causes
  end
  
  def dt_search_by_organization_select
    @partners = [['Choose an Organization', '']]
    Project.partners.each do |partner|
      @partners << [partner.name, partner.id]
    end
    select_tag("partner_id", options_for_select(@partners)) if @partners
  end

  def dt_account_nav
    render 'dt/accounts/account_nav'
  end

  def dt_get_involved_nav
    render 'dt/groups/get_involved_nav'
  end

  def dt_footer
    render 'dt/shared/footer'
  end

  def dt_profile_sidebar
    render 'dt/accounts/profile_sidebar'
  end

  def textilize(text)
    RedCloth.new(text).to_html
  end
end
