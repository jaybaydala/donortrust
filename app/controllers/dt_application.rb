class DtApplicationController < ActionController::Base
  helper :dt_application
  include DtAuthenticatedSystem

  # "remember me" functionality
  before_filter :login_from_cookie
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_donortrustfe_session_id'
end

