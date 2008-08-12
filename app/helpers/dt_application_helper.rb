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

  
  #
  # Shows a spinner when any active AJAX requests are running - Joe
  #
  def show_spinner(message = 'Working')
    content_tag "span","- #{message}... " + image_tag("dt/icons/ajax-spinner.gif", :class => 'icon'), :id => "ajax_busy", :style => "display:none;"
  end
  
  def what_is_this?(id,description)
    result = image_tag('dt/icons/information.png', :border=>0, :alt => 'What is this?')
    result = result + content_tag(:span,blind_down_link("What is This?","what_is_this_#{id}",id),:class => :small_text)
    result + content_tag(:div, ( description + " (" + blind_up_link('Hide',"what_is_this_#{id}",id) + ")"), :id => id, :class => 'what_is_this_box', :style => 'display:none;')  
  end
  
  def blind_down_link(text, id, div)
      link_to_function(text, nil, :id =>id) do |page|
                            page.visual_effect :blind_down, div, :duration => 0.5
                            page.visual_effect :highlight, div, :duration => 2
                   end
  end
  
  def blind_up_link(text, id, div)
      link_to_function(text, nil, :id =>id) do |page|
                            page.visual_effect :blind_up, div, :duration => 0.5
                   end
  end
  
  def blind_down_link_toggle(text, id, div)
      link_to_function(text, nil, :id =>id + "_down") do |page|
                            page.visual_effect :blind_down, div, :duration => 0.5
                            page.visual_effect :highlight, div, :duration => 2
                            page.hide(id + "_down")
                            page.show(id + "_up")
                   end
  end
  
  def blind_up_link_toggle(text, id, div)
      link_to_function(text, nil, :id =>id + "_up", :style => "display:none;") do |page|
                            page.visual_effect :blind_up, div, :duration => 0.5
                            page.hide(id + "_up")
                            page.show(id + "_down")
                   end
  end
  
  def blind_up_down_links(text1,text2, id, div)
      blind_down_link_toggle(text1,id,div) + blind_up_link_toggle(text2, id, div)
  end
  
  def delete_icon(delete_path)
    link_to(image_tag('bus_admin/icons/delete_icon.gif', :style => "vertical-align:middle;", :border => 0),delete_path, :confirm => 'Are you sure?', :method => :delete )
  end
  
  def province_selector(model, field)
    select(model, field, [ 
    	['Select a Province', 'None'],
      ['Alberta', 'AB'],
      ['British Columbia','BC'],
      ['Manitoba','MB'],
      ['New Brunswick','NB'],
      ['Newfoundland and Labrador','NL'],
      ['Northwest Territories','NT'],
      ['Nova Scotia','NS'],
      ['Nunavut','NU'],
      ['Ontario','ON'],
      ['Prince Edward Island','PE'],
      ['Quebec','QC'],
      ['Saskatchewan','SK'],
      ['Yukon','YT']])
  end
  
  def state_selector(model,field)
    select(model, field, [ 	
    	['Select a State', 'None'],
    	['Alabama', 'AL'], 
    	['Alaska', 'AK'],
    	['Arizona', 'AZ'],
    	['Arkansas', 'AR'], 
    	['California', 'CA'], 
    	['Colorado', 'CO'], 
    	['Connecticut', 'CT'], 
    	['Delaware', 'DE'], 
    	['District Of Columbia', 'DC'], 
    	['Florida', 'FL'],
    	['Georgia', 'GA'],
    	['Hawaii', 'HI'], 
    	['Idaho', 'ID'], 
    	['Illinois', 'IL'], 
    	['Indiana', 'IN'], 
    	['Iowa', 'IA'], 
    	['Kansas', 'KS'], 
    	['Kentucky', 'KY'], 
    	['Louisiana', 'LA'], 
    	['Maine', 'ME'], 
    	['Maryland', 'MD'], 
    	['Massachusetts', 'MA'], 
    	['Michigan', 'MI'], 
    	['Minnesota', 'MN'],
    	['Mississippi', 'MS'], 
    	['Missouri', 'MO'], 
    	['Montana', 'MT'], 
    	['Nebraska', 'NE'], 
    	['Nevada', 'NV'], 
    	['New Hampshire', 'NH'], 
    	['New Jersey', 'NJ'], 
    	['New Mexico', 'NM'], 
    	['New York', 'NY'], 
    	['North Carolina', 'NC'], 
    	['North Dakota', 'ND'], 
    	['Ohio', 'OH'], 
    	['Oklahoma', 'OK'], 
    	['Oregon', 'OR'], 
    	['Pennsylvania', 'PA'], 
    	['Rhode Island', 'RI'], 
    	['South Carolina', 'SC'], 
    	['South Dakota', 'SD'], 
    	['Tennessee', 'TN'], 
    	['Texas', 'TX'], 
    	['Utah', 'UT'], 
    	['Vermont', 'VT'], 
    	['Virginia', 'VA'], 
    	['Washington', 'WA'], 
    	['West Virginia', 'WV'], 
    	['Wisconsin', 'WI'], 
    	['Wyoming', 'WY']])
  end

  
  
  # ultrasphinx simple search
  def dt_simple_project_search
    render :partial => 'dt/projects/search', :layout => false
  end
  
  # ultrasphinx advanced search
  # populates select boxes
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
  
  # show sector images when a project_id is given, otherwise, return all sector images
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
