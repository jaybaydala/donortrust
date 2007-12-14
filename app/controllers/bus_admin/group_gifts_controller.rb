require 'csv'
class BusAdmin::GroupGiftsController < ApplicationController
  
  def index
    @page_title = 'Group Gift'
    @groups = GroupGift.find(:all, :conditions => ['sent = 0' ])
  end
  
#  def show
#    @page_title = 'Group Gift'
#    @groups = GroupGift.find(:all)
#  end
  
  def csv_import
    error = ""
    @user = User.find( params[:user][:user_id] )
    @parsed_file=CSV::Reader.parse(params[:dump][:file])    
    n=0    
      @parsed_file.each do |row|
        if row[0] == nil or row[1] == nil or row[2] == nil
          error = "Empty field in row #{n + 1}. Upload Stopped, no gifts sent. "
          break
        else
          c=GroupGift.new
          c.first_name=row[0]
          c.last_name=row[1]
          c.email=row[2]
          c.sent = 0
          if c.save
#           save_gift(c)  
            n=n+1
           GC.start if n%50==0
        end       
      end      
    end
    if error != "" 
      flash[:notice] = error
      redirect_to('/bus_admin/group_gifts/new')
    else if (n * (params[:dump][:amount]).to_i) > @user.balance
      flash[:notice] = "<div id='errorExplanation'>User has insufficient funds to send all gifts. No gifts sent. <br /></div>"
      redirect_to('/bus_admin/group_gifts/new')
    else
      save_gift
      redirect_to('/bus_admin/group_gifts')
      flash[:notice] = "#{n} Gifts created."
    end       
  end
  end
  

   def save_gift
     for group in @group = GroupGift.find(:all, :conditions => ['sent = 0' ])
       @gift = Gift.new  
       @user = User.find(params[:user][:user_id])        
       @gift = Gift.new  
       @gift.amount = params[:dump][:amount]
       @gift.to_name = group.fullname
       @gift.to_email = group.email
       @gift.email = @user.login
       @gift.name =  @user.name
       @gift.message =  params[:dump][:message]
       @gift.e_card_id = 1
       @gift.user_id = params[:user][:user_id]  
       schedule(@gift)      
       @gift.save if @gift      
         if @gift.valid?   
           @gift.send_gift_mail 
           group.sent = 1
           group.save
  #        @gift.send_gift_confirm
         else  
           flash[:notice] = @gift.errors.to_xml        
         end           
       end      
     end
   
  
  def schedule(gift)
    send_at_vals = Array.new
    (1..5).each do |x|
      send_at_vals << params[:dump]["send_at(#{x}i)"] if params[:dump]["send_at(#{x}i)"] && params[:dump]["send_at(#{x}i)"] != ""
    end
    @send_at = Time.utc(send_at_vals[0], send_at_vals[1], send_at_vals[2], send_at_vals[3], send_at_vals[4]) if send_at_vals.length == 5
    gift.send_at = @send_at
    if gift.send_at && params[:time_zone] && params[:time_zone] != ''
      gift.send_at = gift.send_at + -(TimeZone.new(params[:time_zone]).utc_offset)
    end
  end    
  
end     