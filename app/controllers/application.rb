class ApplicationController < ActionController::Base
  include DtApplicationHelper
  include AuthenticatedSystem
  include BusAdmin::UserInfo
  #include BusAdmin::ProjectsHelper
    
  before_filter :set_user
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_donortrust_session_id'
   #before_filter :login_from_cookie
  def login_required
    unless session[:user]
    flash[:notice] = "Please log in" 
    session[:jumpto] = request.parameters
    redirect_to(:controller => "/bus_admin/bus_account", :action => "login")
    end 
  end
  
  def check_authorization
    
    user = BusUser.find(session[:user])
    user_type = user.bus_user_type
    requested_action = action_name
    requested_controller = self.class.controller_path
    unless user_type.bus_secure_actions.detect{|bus_secure_action|
      #  puts "Permitted action: " + bus_secure_action.permitted_actions.to_s + " Desired Action: " + requested_action.to_s + " With controller: " + requested_controller
        if direct_approve(requested_action.to_s, bus_secure_action.permitted_actions.to_s, requested_controller.to_s,bus_secure_action.bus_security_level.controller.to_s ) ||
           indirect_approve(requested_action.to_s, bus_secure_action.permitted_actions.to_s, requested_controller.to_s,bus_secure_action.bus_security_level.controller.to_s )
            return true
        end
      }
      redirect_to('/bus_admin/home')
      flash[:notice] = "You are not authorized to view the page you requested" 
      
      return false
    end
  end

  def dt_login_required
    return true
  end
  
  def direct_approve (requested_action, permitted_action, requested_controller, permitted_controller)
    return (requested_action == permitted_action) && (requested_controller == permitted_controller)
  end
  
  def indirect_approve (requested_action, permitted_action, requested_controller, permitted_controller)
    case(requested_action)
      when ("index")
            return permitted_action == 'list' && (requested_controller == permitted_controller)
      when("update")
             return permitted_action == 'edit' && (requested_controller == permitted_controller)
      when("table")
             return permitted_action == 'list' && (requested_controller == permitted_controller)
      when("destroy")
             return permitted_action == 'delete' && (requested_controller == permitted_controller)
      when("new")
             return permitted_action == 'create' && (requested_controller == permitted_controller)
      when("row")
             return permitted_action == 'list' && (requested_controller == permitted_controller)
      when("nested")
             return permitted_action == 'show' && (requested_controller == permitted_controller)
      when("update_table")
             return permitted_action == 'show' && (requested_controller == permitted_controller)
      when("show_search")
             return permitted_action == 'list' && (requested_controller == permitted_controller)
      when("edit_associated")
             return permitted_action == 'edit' && (requested_controller == permitted_controller)
      when("get_association")
             return permitted_action == 'edit' && (requested_controller == permitted_controller)
      when("change_password_now")
             return permitted_action == 'change_password' && (requested_controller == permitted_controller)
      when("show_encryption")
             return permitted_action == 'change_password' && (requested_controller == permitted_controller)
      when("reset_password_now")
             return permitted_action == 'reset_password' && (requested_controller == permitted_controller)
      when("request_temporary_password")
             return permitted_action == 'reset_password' && (requested_controller == permitted_controller)
      else
            return false
      end
  end
  
  #
  # Like it says, Paginates an array. - Joe
  #
  def paginate_array(page, array, items_per_page)
    @size = array.length
    page ||= 1
    page = page.to_i
    offset = (page - 1) * items_per_page
    pages = Paginator.new(self, array.length, items_per_page, page)
    array = array[offset..(offset + items_per_page - 1)]
    [pages, array]
  end

protected
  def set_user
    BusAdmin::UserInfo.current_user = session[:user]
  end
end

 