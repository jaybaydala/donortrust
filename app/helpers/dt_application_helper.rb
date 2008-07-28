module DtApplicationHelper
  def dt_head
    render 'dt/shared/head'
  end

  def dt_nav
    render 'dt/shared/nav'
  end
  
  def dt_masthead_image
    @image = '/images/dt/feature_graphics/projectsFeature130.jpg'
  end
  
  def dt_american_masthead_image
    @image = '/images/dt/feature_graphics/giftUSTax130.jpg'
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
  
  def dt_action_js
    js = ''
    if @action_js
      if @action_js.class == Array
        @action_js.each do |action_js|
          js += javascript_include_tag action_js
        end
      else
        js = javascript_include_tag @action_js
      end
    end
    js
  end

  def cf_unallocated_project
    Project.cf_unallocated_project
  end

  def cf_admin_project
    Project.cf_admin_project
  end
  
  def form_required
    render :partial => 'dt/shared/form_required'
  end
  
  def cart_empty?
    false
  end
  
  
  # ultrasphinx simple search
  def dt_simple_project_search
    render :partial => 'dt/projects/search', :layout => false
  end
  
  # ultrasphinx advanced search
  def dt_advanced_search
    @continents = [['Location', '']]
		Project.continents_all.each do |place|
  			name = place.parent_id? ? "#{place.name} (#{Place.projects(1,place.id).size})" : "#{place.name} (#{Place.projects(1,place.id).size})"
  			@continents << [name, place.id]
		end
		@partners = [['Organization', '']]
    Project.partners.each do |partner|
      @partners << [partner.name, partner.id]
    end
    @causes = [['Cause', '']]
    Project.causes.each do |cause|
      @causes << [cause.name, cause.id]
    end   
     
    render :partial => 'dt/projects/advanced_search_bar', :layout => false
  end
end
