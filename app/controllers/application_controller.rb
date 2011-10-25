class ApplicationController < ActionController::Base
  filter_parameter_logging :password
  include DtAuthenticatedSystem
  include ExceptionNotifiable
  helper :dt_application
  helper :dashboard
  helper "dt/search"

  #before_filter :set_user
  before_filter :login_from_cookie, :ssl_filter

  # Pick a unique cookie name to distinguish our session data from others'
  # session :session_key => '_donortrustfe_session_id'

  def check_authorization
    return false unless logged_in?
    roles = current_user.roles
    requested_action = action_name
    requested_controller = self.class.controller_path
    requested_controller_id = self
    actions = []
    roles.each do |role|
      role.authorized_actions.each do |action|
        actions << action
      end
    end
    unless actions.detect do |action|
      permitted_actions = AuthorizedAction.find(:all, :conditions => {"authorized_controller_id","#{requested_controller_id}"})
      permitted_actions.each do |permitted_action|
        return true if user_type.bus_secure_action_id == permitted_action.id || indirect_approve()
      end

      #puts "Permitted action: " + action.name + " Desired Action: " + requested_action.to_s + " With controller: " + requested_controller
      return approval?(requested_action.to_s, action.name.to_s, requested_controller.to_s, action.authorized_controller.name.to_s, requested_controller_id)
    end

    flash[:notice] = "You are not authorized to view the requested page."

    if request.parameters.has_value?('_list_inline_adapter') || request.parameters.has_value?('_method=delete')
      render :text => "You do not have access"
    else
      redirect_to('/dt')
    end
    return false
  end
  end
  
  def approval?(requested_action, permitted_action, requested_controller, permitted_controller, requested_controller_id)
    approved = 
      direct_approve(requested_action, permitted_action, requested_controller, permitted_controller) || 
      indirect_approve(requested_action, permitted_action, requested_controller, permitted_controller, requested_controller_id)
    approved
  end

  def direct_approve (requested_action, permitted_action, requested_controller, permitted_controller)
    return (requested_action == permitted_action) && (requested_controller == permitted_controller)
  end

  def indirect_approve (requested_action, permitted_action, requested_controller, permitted_controller, requested_controller_id)
    case(requested_action)
    when ("index")
      return (permitted_action == 'list' || permitted_action == 'show') && (requested_controller == permitted_controller)
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
    when("inactive_records")
      return permitted_action == 'record_management' && (requested_controller == permitted_controller)
    when("recover_record")
      return permitted_action == 'record_management' && (requested_controller == permitted_controller)
    else
      defined? requested_controller_id.get_local_actions(requested_action,permitted_action)
    end
  end

  protected

  def permission_denied
    flash[:notice] = "You don't have privileges to access this action"
    return redirect_to('/dt')
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

  def report_date_range
    if session[:custom_report_start_date].present? && session[:custom_report_end_date].present?
      @start_date = session[:custom_report_start_date]
      @end_date = session[:custom_report_end_date]
    end

    if params[:start_date].present?
      @start_date = Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
      session[:custom_report_start_date] = @start_date
      @end_date = Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)
      session[:custom_report_end_date] = @end_date
    end

    @start_date = Date.today if !@start_date
    @end_date = Date.today if !@end_date
  end

  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end

    render :layout => false
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
