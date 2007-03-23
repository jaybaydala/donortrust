class ProjectCategoriesController < ApplicationController
  # GET /project_categories
  # GET /project_categories.xml
  def index
    @project_categories = ProjectCategory.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @project_categories.to_xml }
    end
  end

  # GET /project_categories/1
  # GET /project_categories/1.xml
  def show
    @project_category = ProjectCategory.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project_category.to_xml }
    end
  end

  # GET /project_categories/new
  def new
    @project_category = ProjectCategory.new
  end

  # GET /project_categories/1;edit
  def edit
    @project_category = ProjectCategory.find(params[:id])
  end

  # POST /project_categories
  # POST /project_categories.xml
  def create
    @project_category = ProjectCategory.new(params[:project_category])

    respond_to do |format|
      if @project_category.save
        flash[:notice] = 'ProjectCategory was successfully created.'
        format.html { redirect_to project_category_url(@project_category) }
        format.xml  { head :created, :location => project_category_url(@project_category) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project_category.errors.to_xml }
      end
    end
  end

  # PUT /project_categories/1
  # PUT /project_categories/1.xml
  def update
    @project_category = ProjectCategory.find(params[:id])

    respond_to do |format|
      if @project_category.update_attributes(params[:project_category])
        flash[:notice] = 'ProjectCategory was successfully updated.'
        format.html { redirect_to project_category_url(@project_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project_category.errors.to_xml }
      end
    end
  end

  # DELETE /project_categories/1
  # DELETE /project_categories/1.xml
  def destroy
    @project_category = ProjectCategory.find(params[:id])
    @project_category.destroy

    respond_to do |format|
      format.html { redirect_to project_categories_url }
      format.xml  { head :ok }
    end
  end
end
