module BusAdmin::ContactsHelper
#   def display_select_box()       
#        render :update do |page|
#          page.replace_html 'the_div', '<p style="color: green;">worked</p>'         
#        end
#   end

  def new_contact_nav
    render 'bus_admin/contacts/new_contact_nav'
  end  
  
  def contact_nav
    render 'bus_admin/contacts/contact_nav'
  end    
  
  def place_form_column
    render 'bus_admin/contacts/_place_form_column'    
  end  

end
