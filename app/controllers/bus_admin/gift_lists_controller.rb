class BusAdmin::GiftListsController < ApplicationController
  

 def unwrap
  
  @gift = Investment.create(:amount =>2, :project_id => 2, :user_id => 2)
  @gift.save  
  #@gift = Investment.create(:amount => params[:record_amount], :project_id => params[:record_project_id], :user_id => params[:record_user_id])
 end
   
end
