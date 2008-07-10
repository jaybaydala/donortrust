class ApplicationController < ActionController::Base
  filter_parameter_logging :password
  include DtAuthenticatedSystem
  helper :dt_application
  helper "dt/search"

  #before_filter :set_user
  before_filter :login_from_cookie, :ssl_filter
  
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

  def check_authorization
    if logged_in?
      user = current_user
      requested_controller = self.class.controller_path
      re = /bus_admin\/*/
      if re.match(requested_controller)
        #if current_user.is_bus_admin?
          return true
        #else
           flash[:notice] = "You are not authorized to view the requested page." 
           redirect_to('/dt')
       # end   
      end

      return true
      #FIXME USER ROLES AUTHENTICATION BYPASSED!
    end
  end

  protected

 def permission_denied
    flash[:notice] = "You don't have privileges to access this action" 
    return redirect_to ('/dt')
  end

  def permission_granted
    # CHANGED: commented the following line as it overrode all the normal flash notices!
    # flash[:notice] = "Welcome to the business administration area!" 
  end

  def ssl_filter
    if ['production'].include?(ENV['RAILS_ENV'])
      redirect_to url_for(params.merge({:protocol => 'https://'})) and return false if !request.ssl? && ssl_required? 
      redirect_to url_for(params.merge({:protocol => 'http://'})) and return false if request.ssl? && !ssl_required? 
    end
  end
  
  #MP - Dec 14, 2007
  #Added to support the us tax receipt functionality
  #allows us to set a value indicating that the user has requested
  #a US tax receipt. If the value is false, the session variable is
  #cleared, otherwise it is set to true
  def requires_us_tax_receipt(value)
    if value
      session[:requires_us_tax_receipt] = value
    else
      session[:requires_us_tax_receipt] = nil unless session[:requires_us_tax_receipt].nil?
    end
  end
  
  #MP - Dec 14, 2007
  #Added to support the us tax receipt functionality
  #If the user has indicated that they want a US tax 
  #receipt, the session variable will be true,
  #otherwise it should be nil.
  def requires_us_tax_receipt?
    return session[:requires_us_tax_receipt] unless session[:requires_us_tax_receipt].nil?
    false
  end

  def ssl_required?
    false
  end

  def log_error(exception) 
    super(exception)
    if ENV['RAILS_ENV'] == 'production'
      begin
        ErrorMailer.deliver_snapshot(
          exception, 
          clean_backtrace(exception), 
          @session.instance_variable_get("@data"), 
          @params, 
          @request.env)
      rescue => e
        logger.error(e)
      end
    end
  end

 # Error Handling
 class DtNotFoundError < Exception
 end
end
