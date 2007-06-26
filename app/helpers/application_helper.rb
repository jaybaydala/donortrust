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
    render 'dt/shared/project_search'
  end
end
