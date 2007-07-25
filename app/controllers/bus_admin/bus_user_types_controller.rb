class BusAdmin::BusUserTypesController < ApplicationController

  active_scaffold :bus_user_types do |config|
    #config.columns[:bus_secure_actions].ui_type = :select
    #config.create.columns.exclude :bus_secure_actions
    #config.columns[:bus_secure_levels].association.reverse = :bus_secure_actions
    
  end
    
   def get_actions    
    controller = BusSecurityLevel.find(params[:bus_security_level_id])
    @actions=  BusSecureAction.find :all, :conditions => ["bus_security_level_id = ?", controller.id]
    result = "<div style='overflow:auto;width:75px;border:1px solid #336699;'><ul style='padding-left:0; margin-left:0;list-style:none;'>"
    for action in @actions 
      result += "<li ><input type='checkbox' id='record_bus_security_level' name='record[bus_secure_actions][" + (action.id - 1).to_s + "][id]' value='" + action.id.to_s + "' " + checked(controller,action) + ">" + action.permitted_actions + "</input></li>"
    end  
    
    result += "</ul></div>"
    render :text => result
  end
  
  def checked(controller,action)
    
#    @condition BusSecureActionsBusUserType.find :first, :conditions => ["bus_secure_action_id = ?" AND "bus_user_type_id = ? ", action.id, params[:id]]
#    if @condition != nil
    
    checked = "";
    if(params[:bus_user_type_id])
      bus_user_type = BusUserType.find(params[:bus_user_type_id])
      for bus_secure_action in bus_user_type.bus_secure_actions
          if bus_secure_action.bus_security_level_id == controller.id && bus_secure_action.id == action.id
            puts "action: " + bus_secure_action.permitted_actions.to_s + " compared to: " + action.permitted_actions.to_s + " CHECKED"
            checked =  ' checked="checked"'
          end
        end
    end
    return checked
  end
  
  
  def prepare_post
    render :text => "you are tryng to complete"
  end
  
end