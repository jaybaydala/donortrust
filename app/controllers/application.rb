
class ApplicationController < ActionController::Base
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
        bus_secure_action.permitted_actions == requested_action && bus_secure_action.bus_security_level.controller == requested_controller
      }
      flash[:notice] = "You are not authorized to view the page you requested" 
      
      return false
     end
  end
protected
  def set_user
    BusAdmin::UserInfo.current_user = session[:user]
  end
end

 