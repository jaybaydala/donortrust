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
  
  def dt_search_by_country_select
    @countries = [['Choose a Country', '']]
    Place.find(:all, :conditions => { :place_type_id => 2 }, :order => :name).each do |country|
      @countries << [country.name, country.id]
    end
    select_tag("country_id", options_for_select(@countries)) if @countries
  end
  
  def dt_search_by_cause_select
    @causes = [['Choose a Cause', '']]
    Sector.find(:all, :conditions => { :parent_id => nil }, :order => :name).each do |sector|
      @causes << [sector.name, sector.id]
      Sector.find(:all, :conditions => { :parent_id => sector.id }, :order => :name).each do |cause|
        @causes << ["- #{cause.name}", cause.id]
      end
    end
    select_tag("sector_id", options_for_select(@causes)) if @causes
  end
  
  def dt_search_by_organization_select
    @partners = [['Choose an Organization', '']]
    Partner.find(:all, :conditions => { :partner_status_id => 1 }, :order => :name).each do |partner|
      @partners << [partner.name, partner.id]
    end
    select_tag("place_id", options_for_select(@partners)) if @partners
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
