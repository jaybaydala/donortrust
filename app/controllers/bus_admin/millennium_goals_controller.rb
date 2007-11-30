class BusAdmin::MillenniumGoalsController < ApplicationController
  before_filter :login_required, :check_authorization


 def index
    @page_title = 'Millennium Goals'
    @goals = MillenniumGoal.find(:all)
    respond_to do |format|
      format.html
    end
  end

   def show
    begin
      @goal = MillenniumGoal.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @goal.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @goal = MillenniumGoal.find(params[:id])
    @goal.destroy
    respond_to do |format|
      format.html { redirect_to millennium_goals_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Millennium Goal Details"
    @goal = MillenniumGoal.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @goal = MillenniumGoal.find(params[:id])
  @saved = @goal.update_attributes(params[:goal])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Millennium Goal was successfully updated.'          
        format.html { redirect_to millennium_goals_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @goal.errors.to_xml }
      end
    end
  end
  
  def create
    @goal = MillenniumGoal.new(params[:goal])
    Cause.transaction do
      @saved= @goal.valid? && @goal.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to millennium_goals_url }
        flash[:notice] = 'Millennium Goal was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end     
  
  def inactive_records
    @page_title = 'Inactive Millennium Goals'       
    @goals = MillenniumGoal.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record
    
    @goal = MillenniumGoal.find_with_deleted(params[:id])
    @goal.deleted_at = nil
    @saved = @goal.update_attributes(params[:goal])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Millennium Goal was successfully recovered.'
        format.html { redirect_to millennium_goals_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @goal.errors.to_xml }
      end
    end
  end
  
end