class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include BusAdmin::UserInfo
  #include BusAdmin::ProjectsHelper
    
  before_filter :set_user
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_donortrust_session_id'
   #before_filter :login_from_cookie
  def login_required
    unless session[:user_id]
    flash[:notice] = "Please log in" 
    session[:jumpto] = request.parameters
    redirect_to(:controller => "/bus_admin/bus_account", :action => "login")
    end 
  end
  
  def check_authorization
    if logged_in?
      user = BusUser.find(session[:user_id])
      user_type = user.bus_user_type
      requested_action = action_name
      requested_controller = self.class.controller_path
      requested_controller_id = self;
      unless user_type.bus_secure_actions.detect{|bus_secure_action|
         permitted_actions = BusSecureAction.find :all, :conditions => {"bus_security_level_id","#{requested_controller_id}"}
         for permitted_action in permitted_actions
            if user_type.bus_secure_action_id == permitted_action.id || indirect_approve()
              return true
            end
         end
        
#          puts "Permitted action: " + bus_secure_action.permitted_actions.to_s + " Desired Action: " + requested_action.to_s + " With controller: " + requested_controller
#          if direct_approve(requested_action.to_s, bus_secure_action.permitted_actions.to_s, requested_controller.to_s,bus_secure_action.bus_security_level.controller.to_s ) ||
#             indirect_approve(requested_action.to_s, bus_secure_action.permitted_actions.to_s, requested_controller.to_s,bus_secure_action.bus_security_level.controller.to_s, requested_controller_id )
#              return true
#          end
        } 
        
        flash[:notice] = "You are not authorized to view the requested page." 

    
        if request.parameters.has_value?('_list_inline_adapter') || request.parameters.has_value?('_method=delete')
          render :text => "You do not have access"
        else
          redirect_to ('/bus_admin/home')
        end
        return false
      end
    else
      return false
    end
  end
  
  def direct_approve (requested_action, permitted_action, requested_controller, permitted_controller)
   
    return (request.parameters.has_value?(permitted_action)) && (requested_controller == permitted_controller)
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
  
def recover_record
    puts self.class.controller_path + " THIS IS HTE CLASS"
    record = self.get_model.find_with_deleted(params[:id])
    record.deleted_at = nil
    record.update
    puts "Redirecting to: " + self.class.controller_path
    redirect_to("/" + self.class.controller_path)
  end
  
  def inactive_records
    @inactive_records = Array.new(self.get_model.count_with_deleted("deleted_at = !null"))
    @record = self.get_model
     for record in self.get_model.find_with_deleted(:all)
        if record.deleted_at != nil
           @inactive_records.push(record)
        end
     end
    if !@inactive_records.empty?
      render :partial => 'bus_admin/deleted_records/inactive_records'
    else
      render :text => "There are no deleted records"
    end
    
  end
  
protected
  def set_user
    BusAdmin::UserInfo.current_user = session[:user]
  end


end