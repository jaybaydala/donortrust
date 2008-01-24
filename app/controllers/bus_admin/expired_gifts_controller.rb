require 'net/http'
require 'uri'
class BusAdmin::ExpiredGiftsController < ApplicationController
  before_filter :login_required, :check_authorization
  def index
    @gifts = Gift.find(:all, :conditions => ['sent_at < ? and picked_up_at is null', 31.days.ago])
   # render :partial => "list", :layout => false
  end
  
 def unwrap
  @giftId = params[:gift_id]
  @gift = Gift.find(@giftId)
  
   @gift.picked_up_at = Time.now
  @gift.save! if @gift
  
  if not @gift.project_id?
    @gift.project_id =  params[:projectId]
  end
  @investment = Investment.new_from_gift(@gift, @gift.user_id)
  @investment.save! if @investment
   respond_to do |format|
  if @investment.valid?
   flash[:notice] = 'Investment was successfully created.'
    @gifts = Gift.find(:all, :conditions => ['sent_at < ? and picked_up_at is null', 31.days.ago])
   format.html {render :partial => 'list', :layout => false }
   format.xml  { head :ok }
 else
    format.html {render :partial => 'list', :layout => false }
   format.xml  { render :xml => @investment.errors.to_xml }
  end
  # render(:update) { |page| page.call 'location.reload' }
end
 end
   

end
