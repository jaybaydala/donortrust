
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
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
  
  
  
end
