module ApplicationHelper
  #include AuthenticatedSystem

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
    @partner_select = select("parnter_select", "partner_id", projects, { :prompt => '--Select a Partner--' } )
    render 'dt/shared/project_search'
  end  
  
  def show_message_and_reset(message, type)   
    message_div = 'message_div'
    @color = "black"
    case type
      when "error" 
        @color = "red"
      when warning
        @color = "yellow"
      when info
        @color = "green"
    end
         render :update do |page|
        page.replace_html message_div, '<p style="color: ' + @color + ';">' + message + '</p>' 
        page.delay(5) do          
          page.replace_html message_div, ''  
        end
    end
  end
  
end
