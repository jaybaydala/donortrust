class DtApplicationController < ActionController::Base
  layout 'application'
  filter_parameter_logging :password, :credit_card, :card_number, :tmp_card_number
  helper :dt_application
  helper :dashboard
  helper "dt/search"
  include DtAuthenticatedSystem
  include ExceptionNotifiable
  helper_method :ssl_available?
  helper_method :country_code

  # http auth for staging
  before_filter :authenticate_via_http
  # "remember me" functionality
  before_filter :login_from_cookie, :ssl_filter
  before_filter :new_feedback
  before_filter :country_code
  
  # Pick a unique cookie name to distinguish our session data from others'
  # session :session_key => '_donortrustfe_session_id'
  
  protected

    def country_code
      if( session[:country_code].nil? || request.remote_ip != session[:country_code_ip] )
        session[:country_code] = Geolocation.lookup(request.remote_ip)
        session[:country_code_ip] = request.remote_ip
        Rails.logger.debug "Session country code lookup: #{session[:country_code]}"
      else
        Rails.logger.debug "Session country code still valid: #{session[:country_code]}"
      end
      session[:country_code]
    end

    def authenticate_via_http
      if Rails.env.staging?
        authenticate_or_request_with_http_basic do |username, password|
          username == "staging" && password == "endpoverty!"
        end
      end
    end

    def ssl_filter
      if ssl_available?
        if !request.ssl? && ssl_required? 
          flash.keep
          redirect_to url_for(params.merge({:protocol => 'https://'})) and return false
        end
        if request.ssl? && !ssl_required? 
          flash.keep
          redirect_to url_for(params.merge({:protocol => 'http://'})) and return false
        end
      end
    end
  
    def ssl_available?
      return Rails.env.production?
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

    def new_feedback
      @feedback = Feedback.new
      if logged_in?
        @feedback.attributes = { :email => current_user.email, :name => current_user.full_name }
      end
    end

  private

    def render_404
      respond_to do |type|
        type.html { render :template => "dt/shared/errors/error404", :layout => "application", :status => "404" }
        type.all  { render :nothing => true, :status => "404 Not Found" }
      end
    end

    def render_500
      respond_to do |type|
        type.html { render :template => "dt/shared/errors/error", :layout => "application", :status => "500" }
        type.all  { render :nothing => true, :status => "500 Error" }
      end
    end

end
