class MilestoneCategoriesController < ApplicationController
  # GET /milestone_categories
  # GET /milestone_categories.xml
  def index
    @milestone_categories = MilestoneCategory.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @milestone_categories.to_xml }
    end
  end

  # GET /milestone_categories/1
  # GET /milestone_categories/1.xml
  def show
    @milestone_category = MilestoneCategory.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @milestone_category.to_xml }
    end
  end

  # GET /milestone_categories/new
  def new
    @milestone_category = MilestoneCategory.new
  end

  # GET /milestone_categories/1;edit
  def edit
    @milestone_category = MilestoneCategory.find(params[:id])
  end

  # POST /milestone_categories
  # POST /milestone_categories.xml
  def create
    @milestone_category = MilestoneCategory.new(params[:milestone_category])

    respond_to do |format|
      if @milestone_category.save
        flash[:notice] = 'MilestoneCategory was successfully created.'
        format.html { redirect_to milestone_category_url(@milestone_category) }
        format.xml  { head :created, :location => milestone_category_url(@milestone_category) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone_category.errors.to_xml }
      end
    end
  end

  # PUT /milestone_categories/1
  # PUT /milestone_categories/1.xml
  def update
    @milestone_category = MilestoneCategory.find(params[:id])

    respond_to do |format|
      if @milestone_category.update_attributes(params[:milestone_category])
        flash[:notice] = 'MilestoneCategory was successfully updated.'
        format.html { redirect_to milestone_category_url(@milestone_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone_category.errors.to_xml }
      end
    end
  end

  # DELETE /milestone_categories/1
  # DELETE /milestone_categories/1.xml
  def destroy
    @milestone_category = MilestoneCategory.find(params[:id])
    @milestone_category.destroy

    respond_to do |format|
      format.html { redirect_to milestone_categories_url }
      format.xml  { head :ok }
    end
  end
end
