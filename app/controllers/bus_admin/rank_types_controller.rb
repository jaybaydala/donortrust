class BusAdmin::RankTypesController < ApplicationController
  
  #before_filter :login_required, :check_authorization
  

  def index
    @page_title = 'Rank Types'
    @ranks = RankType.find(:all)
    respond_to do |format|
      format.html
    end
  end

   def show
    begin
      @rank = RankType.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @rank.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @rank = RankType.find(params[:id])
    @rank.destroy
    respond_to do |format|
      format.html { redirect_to rank_types_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Rank type Details"
    @rank = RankType.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @rank = RankType.find(params[:id])
  @saved = @rank.update_attributes(params[:rank])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Rank Type was successfully updated.'
        format.html { redirect_to rank_type_path(@rank) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rank.errors.to_xml }
      end
    end
  end
  
  def create
    @rank = RankType.new(params[:rank])
    Cause.transaction do
      @saved= @rank.valid? && @rank.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to rank_types_url }
        flash[:notice] = 'Rank Type was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end     
  
end