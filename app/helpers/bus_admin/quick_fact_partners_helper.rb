module BusAdmin::QuickFactPartnersHelper

  def quick_facts_nav
    render 'bus_admin/quick_fact_partners/_quick_facts_nav'
  end
  
  def new_quick_fact_nav
    render 'bus_admin/quick_fact_partners/_new_quick_fact_nav'
  end
   
  def quick_fact_types
    QuickFact.find(:all)
  end
  
  
  def quick_fact_type_names
    QuickFactType.find(:all) 
  end
  
  def quick_fact_names
    QuickFact.find(:all, :conditions => ['quick_fact_type_id = 2' ]) # number needs to equal the quick_fact_types Organization id
  end
  
end
