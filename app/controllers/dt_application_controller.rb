class DtApplicationController < ActionController::Base
  helper :dt_application
  include DtAuthenticatedSystem

  # "remember me" functionality
  before_filter :login_from_cookie
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_donortrustfe_session_id'
  
  def rescue_404
    rescue_action_in_public DtNotFoundError.new
  end
    
  def rescue_action_in_public(exception)
    case exception.to_s
      when /DtNotFoundError/, /RoutingError/, /UnknownAction/
        render :template => "dt/shared/errors/error404", :layout => "dt_application", :status => "404"
      else
        @message = exception
        render :template => "dt/shared/errors/error", :layout => "dt_application", :status => "500"
    end
  end
  
  def local_request?
    return false
  end

 #protected  
 #
 #def log_error(exception) 
 #  super(exception)
 #  begin
 #    ErrorMailer.deliver_snapshot(
 #      exception, 
 #      clean_backtrace(exception), 
 #      @session.instance_variable_get("@data"), 
 #      @params, 
 #      @request.env)
 #  rescue => e
 #    logger.error(e)
 #  end
 #end

 # Error Handling
 class DtNotFoundError < Exception
 end
end
