class BusAdmin::UsersController < ApplicationController
#  before_filter :login_required , :check_authorization
   
  def index
    @page_title = 'Donors'
    @users = User.find(:all)#, :conditions => { :featured => 1 })
    respond_to do |format|
      format.html
    end
  end
  
  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @user.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Donor Details"
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update    
  @user = User.find(params[:id])
  @saved = @user.update_attributes(params[:user])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Donor was successfully updated.'
        format.html { redirect_to user_path(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end  

end

