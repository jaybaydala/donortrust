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
    @continents = [['All ...', '']]
		Project.continents_all.each do |place|
  			name = place.parent_id? ? "#{place.name} (#{Place.projects(1,place.id).size})" : "#{place.name} (#{Place.projects(1,place.id).size})"
  			@continents << [name, place.id]
		end
		@partners = [['All ...', '']]
    Project.partners.each do |partner|
      @search = Ultrasphinx::Search.new(:class_names => 'Project', :per_page => Project.count, :filters => {:partner_id => partner.id})
      @search.run
      projects = @search.results
      @partners << ["#{partner.name} (#{projects.size})", partner.id]
    end
    @causes = [['All ...', '']]
    Project.causes.each do |cause|
       @search = Ultrasphinx::Search.new(:class_names => 'Project', :per_page => Project.count, :filters => {:cause_id => cause.id})
       @search.run
       projects = @search.results
       if projects.size>0
         @causes << ["#{cause.name} (#{projects.size})", cause.id]
       end
    end   
    
    @sectors = [['All ...', '']]
    Project.sectors.each do |sector|
       @search = Ultrasphinx::Search.new(:class_names => ['Project'], :per_page => Project.count, :filters => {:sector_id => sector.id})
       @search.run
       projects = @search.results
       if projects.size>0
         @sectors << ["#{sector.name} (#{projects.size})", sector.id]
       end
    end
     
    render :partial => 'dt/projects/advanced_search_bar', :layout => false
  end
  
  def sector_images(project_id=nil)
    output = []
    if project_id
      sectors = Project.find(project_id).sectors
      sectors.each do | sector|
        output << image_tag("/images/dt/sectors/#{sector.image_name}",  :title=> sector.name, :alt => sector.name)
      end
    else
      Sector.find(:all).each do |sector|
        output << image_tag("/images/dt/sectors/#{sector.image_name}", :title=> sector.name, :alt => sector.name)
      end
    end
    return output.join "\n"
  end
  

  
end
