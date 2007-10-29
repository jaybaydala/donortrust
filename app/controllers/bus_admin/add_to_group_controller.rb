class BusAdmin::AddToGroupController < ApplicationController
  
  
 def index
    @members = Load.find(:all, :conditions => ['invitation = 0' ])
  end
  
  def add_to_groups
    
    for load in @load = Load.find(:all, :conditions => ['invitation = 0' ])
          
      @invitation = Invitation.new(params[:invitation])
      
      @invitation.user_id = 5
      @invitation.group_id = 5
      @invitation.to_name = load.name
      @invitation.to_email = load.email
      @invitation.message = 'message'
      @invitation.ip = request.remote_ip
      
      @invitation.save if @invitation      
      if @invitation.valid?
        flash[:notice] = 'Invitations were successfully created.'
        load.invitation = 1
        load.save
      else
          flash[:notice] = @invitation.errors.to_xml 
          break
      end   
    end
  render(:update) { |page| page.call 'location.reload' }
  end  
     
end

  