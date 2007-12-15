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
end
