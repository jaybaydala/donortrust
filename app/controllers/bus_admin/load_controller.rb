class BusAdmin::LoadController < ApplicationController

  def index
    @loads = Load.find(:all , :conditions => ['sent = 0' ])
  end
  
  def loads    
      
    for load in @load = Load.find(:all , :conditions => ['sent = 0' ])
      
      @gift = Gift.new  
         
      @gift.amount = 5
      @gift.to_name = load.name
      @gift.to_email = load.email
      @gift.email = 'whoitsfrom@hotmail.com' 
      @gift.name =  'from me'
      @gift.message = 'free cash'
      @gift.ecard= '/images/dt/ecards/large/cf-ecard-001.jpg' 
      @gift.city = 'Canada'
      @gift.postal_code = 'T2T 4B2'
      @gift.card_expiry = '04/09'
      @gift.credit_card = 4111111111111111
      @gift.country = 'CA'
      @gift.first_name  = 'firstName'
      @gift.last_name = 'none'
      @gift.province = 1
      @gift.address = '1234 5th Ave SW' 
      @gift.user_id = 1       
      
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

