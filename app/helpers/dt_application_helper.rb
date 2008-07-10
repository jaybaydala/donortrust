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
  def show_spinner
    content_tag "div", "Working... " + image_tag("/images/bus_admin/spinner.gif"), :id => "ajax_busy", :style => "display:none;"
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
end
