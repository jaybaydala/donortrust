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
    projects = Project.find_public(:all, :include => :place)
    all_places = []
    projects.each do |project|
      if project.nation
        all_places << project.nation.parent.id if project.nation.parent && !all_places.include?(project.nation.parent.id) # continent
        all_places << project.nation.id if !all_places.include?(project.nation.id)
      end
    end
    @places = [['Choose a Place', '']]
    Place.find(all_places, :order => "parent_id, name").each do |place|
      name = place.parent_id? ? "- #{place.name}" : place.name
      @places << [name, place.id]
    end
    select_tag("place_id", options_for_select(@places)) if @places
  end
  
  def dt_search_by_cause_select
    projects = Project.find_public(:all, :include => :causes)
    @causes = [['Choose a Cause', '']]
    projects.each do |project|
      project.causes.each do |cause|
        @causes << [cause.name, cause.id]
      end
    end
    select_tag("cause_id", options_for_select(@causes)) if @causes
  end
  
  def dt_search_by_organization_select
    projects = Project.find_public(:all, :include => :partner)
    @partners = [['Choose an Organization', '']]
    projects.each do |project|
      @partners << [project.partner.name, project.partner.id]
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
