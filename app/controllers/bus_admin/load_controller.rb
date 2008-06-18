class BusAdmin::LoadController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 

  def index
    @loads = Load.find(:all , :conditions => ['sent = 0' ])
  end
  
  def loads    
      
    for load in @load = Load.find(:all , :conditions => ['sent = 0' ])
      
      @gift = Gift.new  
         
      @gift.amount = 5
      @gift.to_name = load.name
      @gift.to_email = load.email
      @gift.email = 'desireemckee@hotmail.com' 
      @gift.name =  'Jay Baydala'
      @gift.message = 'I can\'t imagine a better way to celebrate the launch of ChristmasFuture 
than to start changing the world! This is our gift to you - invest it 
in a project or gift it to a loved one...you choose! Either way we ALL 
win!

Happy Holidays,

...Jay'
      @gift.e_card_id = 8
   #   @gift.city = 'Canada'
   #   @gift.postal_code = 'T2T 4B2'
   #   @gift.card_expiry = '04/09'
   #  @gift.credit_card = 4111111111111111
   #   @gift.country = 'CA'
   #   @gift.first_name  = 'firstName'
   #   @gift.last_name = 'none'
   #   @gift.province = 1
   #   @gift.address = '1234 5th Ave SW' 
      @gift.user_id = 3 
      
      @gift.save if @gift      
        if @gift.valid?
          flash[:notice] = 'Gifts were successfully created.'
          @gift.send_gift_mail 
          load.sent = 1
          load.save
          @gift.send_gift_confirm
        else
          flash[:notice] = @gift.errors.to_xml 
          break
        end   
    end
    render(:update) { |page| page.call 'location.reload' }
  end  
   
end

