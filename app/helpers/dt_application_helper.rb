module DtApplicationHelper
  
  def dt_head
    render 'dt/shared/head'
  end

  def dt_nav
    render 'dt/shared/nav'
  end

  def dt_masthead
    @masthead = { 
      :image => '/images/dt/masthead_default.jpg'
      }
    render 'dt/shared/masthead'
  end

  def dt_project_search
    projects = Project.find(:all).collect {|p| [ p.name, p.id ] }
    @project_select = select("project_select", "project_id", projects, { :prompt => '--Select a Project--' }, { :onchange => "window.location.href='#{dt_search_projects_path}?project_id='+this.options[this.selectedIndex].value" } )
    countries = Country.find(:all).collect {|p| [ p.name, p.id ] }
    @country_select = select("country_select", "country_id", projects, { :prompt => '--Select a Region--' } )
    partners = Partner.find(:all).collect {|p| [ p.name, p.id ] }
    @partner_select = select("partner_select", "partner_id", projects, { :prompt => '--Select a Partner--' } )
    render 'dt/shared/project_search'
  end  
end
