class BusAdmin::GiftsController < ApplicationController
  

 def unwrap
  @giftId = params[:gift_id]
  @gift = Gift.find(@giftId)
  if not @gift.project_id?
    @gift.project_id =  params[:project_id]
  end
  @investment = Investment.new_from_gift(@gift, @gift.user_id)
  @investment.save! if @investment
  #@gift = Investment.create(:amount => params[:record_amount], :project_id => params[:record_project_id], :user_id => params[:record_user_id])
   render :partial => "bus_admin/gifts/unwrap"
 
 end
   
end
