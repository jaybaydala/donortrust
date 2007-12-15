module BusAdmin::BusUserTypesHelper

  
  def checked(controller, action, bus_user_type_id)       
    checked = "";
    if(bus_user_type_id)
      bus_user_type = BusUserType.find(bus_user_type_id)
      for bus_secure_action in bus_user_type.bus_secure_actions
          if bus_secure_action.bus_security_level_id == controller.id && bus_secure_action.id == action.id
            #puts "action: " + bus_secure_action.permitted_actions.to_s + " compared to: " + action.permitted_actions.to_s + " CHECKED"
            checked =  ' checked="checked"'
          end
        end
    end
    return checked
  end
end
