module BusAdmin::RolesHelper

#hack to hide active_scaffold add_existing form
  def options_for_association_conditions(association)
    if association.name == :administrations
      ['false']
    else
      super
    end
  end

 # def permissions_form_column(record, name)
 #    select record.to_s, "permission.id", :name => name
 # end  

end
