module BusAdmin::GroupGiftsHelper
  
  def get_users
     User.find(:all)
  end  
end
