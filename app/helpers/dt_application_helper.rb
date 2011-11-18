require "recaptcha"
module DtApplicationHelper
  include ReCaptcha::ViewHelper
  def recaptcha_available?
    !RCC_PUB.nil? && !RCC_PRIV.nil?
  end

  def current_nav?(controllers, actions=nil)
    current = false
    if (actions.present? && [*actions].flatten.include?(action_name) && [*controllers].flatten.include?(controller_name)) ||
      (actions.blank? && [*controllers].flatten.include?(controller_name))
      current = true
    end
    current
  end

  def content_snippet_for(slug)
    content_snippet = ContentSnippet.find_by_slug(slug.to_s)
    if content_snippet.present?
      content_tag(:p, ContentSnippet.find_by_slug(slug.to_s).body_formatted)
    end
  end

  def unformatted_content_snippet_for(slug)
    content_snippet = ContentSnippet.find_by_slug(slug.to_s)
    if content_snippet.present?
      ContentSnippet.find_by_slug(slug.to_s).body
    end
  end

  def auth_path(provider)
    "/auth/#{provider.to_s}"
  end

  def link_to_upload_file(link_text, upload_id)
    if Upload.exists?(upload_id)
      link_to(link_text, Upload.find(upload_id).file.url)
    else
      link_text
    end
  end
  
  def show_title?
    true
  end

  def title(str)
    content_for(:title) { str.to_s }
  end

  def html_title(str)
    content_for(:html_title) { str.to_s }
  end
  
  def content_for?(name)
    ivar = "@content_for_#{name}"
    instance_variable_get(ivar).present?
  end

  def ssl_protocol
    Rails.env.production? ? 'https://' : 'http://'
  end
  
  def dt_head
    render :file => 'dt/shared/head'
  end

  def dt_nav
    render :file => 'dt/shared/nav'
  end

  def dt_masthead_image
    @image = '/images/dt/feature_graphics/projectsFeature130.jpg'
  end

  def dt_american_masthead_image
    @image = '/images/dt/feature_graphics/giftUSTax130.jpg'
  end

  def iend_user_nav
    render :partial => 'iend/shared/iend_nav'
  end

  def dt_get_involved_nav
    render :file => 'dt/groups/get_involved_nav'
  end

  def dt_profile_sidebar
    render :file => 'dt/accounts/profile_sidebar'
  end

  def dt_short_profile_sidebar
    render :file => 'dt/accounts/short_profile_sidebar'
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

  def unallocated_project
    Project.unallocated_project
  end

  def admin_project
    Project.admin_project
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
    content_tag "span","- #{message}... " + image_tag("dt/icons/ajax-spinner.gif", :class => 'icon', :alt => ""), :id => "ajax_busy", :style => "display:none;"
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

  def blind_down_link_toggle(text, id, div, style)
      link_to_function(text, nil, :id =>id + "_down", :style => style) do |page|
                            page.visual_effect :blind_down, div, :duration => 0.5
                            page.visual_effect :highlight, div, :duration => 2
                            page.hide(id + "_down")
                            page.show(id + "_up")
                   end
  end

  def blind_up_link_toggle(text, id, div, style)
      link_to_function(text, nil, :id =>id + "_up", :style => style) do |page|
                            page.visual_effect :blind_up, div, :duration => 0.5
                            page.hide(id + "_up")
                            page.show(id + "_down")
                   end
  end

  def blind_up_down_links(text1,text2, id, div)
      blind_up_link_toggle(text2, id, div, '') + blind_down_link_toggle(text1,id,div,'display:none;')
  end

  def blind_down_up_links(text1,text2, id, div)
      blind_down_link_toggle(text1,id,div,'') + blind_up_link_toggle(text2, id, div, 'display:none;')
  end

  def delete_icon(delete_path)
    link_to(image_tag('bus_admin/icons/delete_icon.gif', :style => "vertical-align:middle;", :border => 0),delete_path, :confirm => 'Are you sure you want to delete this?', :method => :delete )
  end

  def campaign_h2_header(content, target_div, collapsed=false)
    if !collapsed
      '<h2 class="campaign">' + blind_up_down_links(image_tag('dt/icons/expand_icon.png',:border=>0),image_tag('dt/icons/collapse_icon.png',:border=>0),'expand_' + target_div,target_div) + content + '</h2>'
    else
      '<h2 class="campaign">' + blind_down_up_links(image_tag('dt/icons/expand_icon.png',:border=>0),image_tag('dt/icons/collapse_icon.png',:border=>0),'expand_' + target_div,target_div) + content + '</h2>'
    end
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
  			name = place.id? ? "#{place.name} (#{place.public_projects.size})" : "#{place.name} (#{place.public_projects.size})"
  			@continents << [name, place.id]
		end

    #@countries = [['All ...', '']]
    #Project.project_countries.each do |place|
    #    name = place.id? ? "#{place.name} (#{place.public_projects.size})" : "#{place.name} (#{place.public_projects.size})"
    #    @countries << [name, place.id]
    #end

		@partners = [['All ...', '']]
    Project.partners.each do |partner|
      #@prjts = Ultrasphinx::Search.new(:class_names => 'Project', :per_page => Project.count, :filters => {:partner_id => partner.id})
      #@prjts.run
      #projects = @prjts.results
      projects = Project.find(:all, :conditions => "projects.partner_id =#{partner.id}")
      @partners << (["#{partner.name} (#{projects.size})", partner.id]) if !projects.size.nil?
    end
    #@causes = [['All ...', '']]
    #Project.causes.each do |cause|
    #   @search = Ultrasphinx::Search.new(:class_names => 'Project', :per_page => Project.count, :filters => {:cause_id => cause.id})
    #   @search.run
    #   projects = @search.results
    #   if projects.size>0
    #     @causes << ["#{cause.name} (#{projects.size})", cause.id]
    #   end
    #end

    @sectors = [['All ...', '']]
    Sector.find(:all).each do |sector|
      if sector.projects.size>0
         @sectors << ["#{sector.name} (#{sector.projects.size})", sector.id]
      end
    end

   render :partial => 'dt/projects/advanced_search_bar', :layout => false
  end

  # show sector images when a project_id is given
  def sector_images(project_id=nil)
    output = []
    if project_id
      sectors = Project.find(project_id).sectors
      sectors.each do | sector|
        output << image_tag("/images/dt/sectors/#{sector.image_name}", :title=> sector.name, :alt => sector.name, :class=>"sector-icon")
      end
    end
    return output.join("\n")
  end

  # Truncates HTML text at /length/ characters and appends '...'.  If
  # strip tags is true, HTML tags will be stripped.  Otherwise, unbalanced
  # HTML tags will be closed.
  #
  # = Restrictions
  #
  #  * Comments break it.
  #  * Processing instructions break it.
  #
  def summarize_html(text, length = 100, strip_tags = true)
    if text.nil?
      return nil
    end

    if strip_tags
      summary = text.gsub(/\<[^\>]*\>/, '')
    else
      summary = text.clone
    end

    if summary.length > length
      summary = summary[0...length]
      summary += '...'
    end

    # Make sure we did not cut a tag in half at the end of text
    lt_idx = summary.rindex('<')
    gt_idx = summary.rindex('>')

    lt_idx = 0 if lt_idx.nil?
    gt_idx = 0 if gt_idx.nil?

    if lt_idx > gt_idx
      # Bah!  We've ripped a tag in half.  Throw it away!
      summary = summary[0...lt_idx]
    end

    # Search for imbalanced tags
    tag_list = []
    tag_regex = /\<\s*(\/?)(\w+).*?(\/)?\>/
    summary.scan(tag_regex) { |slash, tag, tag_close|
      if tag_close != '/'
        if slash == ''
          tag_list.push(tag)
        else slash
          tag_list.pop()
        end
      end
    }

    # Close imbalanced tags
    tag_list = tag_list.reverse
    for tag in tag_list
      summary += "</#{tag}>"
    end

    # Return summarized strings
    return summary
  end
  
  def action_button(text, link, options = {})
    link_to text, link, options.merge(:class => 'action_button')
  end

  def action_button_remote(text, link, options = {})
    link_to_remote text, link, options.merge(:class => 'action_button')
  end

  def display_add_as_friend_button
    if logged_in? && @user != current_user && !current_user.friends_with?(@user)
      link_to "+ Add as friend", iend_friendships_path(:friend_id => @user.id), :id => "add_as_friend", :method => :post, :class => "smallbutton"
    end
  end

end
