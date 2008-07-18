require 'csv'

class BusAdmin::GroupGiftsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'' 
  
  def index
    @page_title = 'Group Gift'
    @groups = GroupGift.find(:all)
  end
  
  def show
    @page_title = 'Group Gift'
    @groups = GroupGift.find(:all)
  end
  
  def csv_import
    delete_sent
    error = check_fields
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
        c.sent = false
        if c.save
         n=n+1
         GC.start if n%50==0
        end       
      end      
    end
    if error != "" 
      flash[:error] = error
      redirect_to('/bus_admin/group_gifts/new')
      else if (n * (params[:dump][:amount]).to_i) > @user.balance
        flash[:error] = "<div id='errorExplanation'>User has insufficient funds to send all gifts. No gifts sent. <br /></div>"
        redirect_to('/bus_admin/group_gifts/new')
      else
        save_gift
        redirect_to('/bus_admin/group_gifts/show')
        flash[:notice] = "#{n} Gifts created."
      end       
    end
  end
  
  def check_fields
    error =""
    if   params[:user][:user_id].nil? or  params[:user][:user_id]  == ""
       error = "Sent By must be selected"
     else
       @user = User.find( params[:user][:user_id] )       
    end
    if params[:dump][:amount].nil? or params[:dump][:amount] == ""       
      error = "Amount is empty"
      else if params[:dump][:file].nil? or params[:dump][:file] == ""       
        error = "File is empty or does not exist"    
      end
    end 
    error = error
  end  

  def delete_sent
    for group in @group = GroupGift.find(:all)
      group.destroy
    end
  end
  
  def save_gift 
    @ecard = ECard.find(:first)
    for group in @group = GroupGift.find(:all)
      @gift = Gift.new  
      @user = User.find(params[:user][:user_id])        
      @gift = Gift.new  
      @gift.amount = params[:dump][:amount]
      @gift.to_name = group.fullname
      @gift.to_email = group.email
      @gift.email = @user.login
      @gift.name =  @user.full_name
      @gift.message =  params[:dump][:message]
      @gift.e_card_id = @ecard.id.to_i
      @gift.user_id = params[:user][:user_id] 
      schedule(@gift)      
      @gift.save if @gift      
       if @gift.valid?   
         if @gift.send_at == nil           
           @gift.send_gift_mail  
         end  
         @gift.send_gift_confirm
         group.sent = true
         group.save
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