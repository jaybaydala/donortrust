class DtApplicationController < ActionController::Base
  filter_parameter_logging :password, :credit_card
  helper :dt_application
  helper "dt/search"
  include DtAuthenticatedSystem

  # "remember me" functionality
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
  
  protected
  def ssl_filter
    if ['staging', 'production'].include?(ENV['RAILS_ENV'])
      redirect_to url_for(params.merge({:protocol => 'https://'})) and return false if !request.ssl? && ssl_required? 
      redirect_to url_for(params.merge({:protocol => 'http://'})) and return false if request.ssl? && !ssl_required? 
    end
  end

  def ssl_required?
    return false
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
