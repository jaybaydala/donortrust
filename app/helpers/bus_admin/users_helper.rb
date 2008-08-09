module BusAdmin::UsersHelper

  def options_for_association_conditions(association)
    if association.name == :administrations
      ['false']
    else
      super
    end
  end

end
