class BusAdmin::BusUserTypesController < ApplicationController

  active_scaffold :bus_user_types do |config|
    #config.columns[:bus_secure_actions].ui_type = :select
    #config.create.columns.exclude :bus_secure_actions
    #config.columns[:bus_secure_levels].association.reverse = :bus_secure_actions
    
  end
  
  def get_actions
    controller = BusSecurityLevel.find(params[:bus_security_level_id])
    @actions=  BusSecureAction.find :all, :conditions => ["bus_security_level_id = ?", controller.id]
    result = "<select id='record_bus_security_level' name='record[bus_secure_actions][bus_security_level][id]'> "
    for action in @actions
      result += "<option value=" + action.id.to_s + ">" + action.permitted_actions + "</option> "
    end
    result += "</select>"
    puts result
    render :text => result
  end
  
#   def get_actions
#    controller = BusSecurityLevel.find(params[:bus_security_level_id])
#    @actions=  BusSecureAction.find :all, :conditions => ["bus_security_level_id = ?", controller.id]
#    #result = "<div id='record_bus_security_level' name='record[bus_secure_actions][bus_security_level][id]'> "
#    result = "<div style='overflow:auto;width:75px;height:75px;border:1px solid #336699;padding-left:5px'>"
#    for action in @actions
#      result += "<input type='checkbox' name=" + record[bus_secure_actions][bus_security_level] + ">" + action.permitted_actions + "</option> "
#    end
#    result += "</div>"
#    puts result
#    render :text => result
#  end
  
end