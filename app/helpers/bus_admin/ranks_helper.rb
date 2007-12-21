module BusAdmin::RanksHelper
  
  def user_can_alter_ranks
    current_busaccount.role_one_of?(:admin, :cfadmin)
  end
  
end
