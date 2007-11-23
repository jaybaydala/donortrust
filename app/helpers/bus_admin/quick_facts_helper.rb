module BusAdmin::QuickFactsHelper

  def quick_fact_all_types
    QuickFactType.find(:all)
  end
  
  def quick_fact_types
    QuickFact.find(:all)
  end
  
  def quick_fact_nav
    render 'bus_admin/quick_facts/_quick_fact_nav'
  end
  
  def quick_fact_new_nav
    render 'bus_admin/quick_facts/_quick_fact_new_nav'
  end
    
end
