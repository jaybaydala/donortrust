class NationsController < ApplicationController
 before_filter :get_data
 
  # GET /nations
  # GET /nations.xml
  def index
    @nations = Nation.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @nations.to_xml }
    end
  end

  # GET /nations/1
  # GET /nations/1.xml
  def show
    @nation = Nation.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @nation.to_xml }
    end
  end

  # GET /nations/new
  def new
    @nation = Nation.new
  end

  # GET /nations/1;edit
  def edit
    @nation = Nation.find(params[:id])
  end

  # POST /nations
  # POST /nations.xml
  def create
    @nation = Nation.new(params[:nation])

    respond_to do |format|
      if @nation.save
        flash[:notice] = 'Nation was successfully created.'
        format.html { redirect_to nation_url(@nation) }
        format.xml  { head :created, :location => nation_url(@nation) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nation.errors.to_xml }
      end
    end
  end

  # PUT /nations/1
  # PUT /nations/1.xml
  def update
    @nation = Nation.find(params[:id])

    respond_to do |format|
      if @nation.update_attributes(params[:nation])
        flash[:notice] = 'Nation was successfully updated.'
        format.html { redirect_to nation_url(@nation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nation.errors.to_xml }
      end
    end
  end

  # DELETE /nations/1
  # DELETE /nations/1.xml
  def destroy
    @nation = Nation.find(params[:id])
    @nation.destroy

    respond_to do |format|
      format.html { redirect_to nations_url }
      format.xml  { head :ok }
    end
  end
  
  def get_data
    @continents = Continent.find(:all)

  end
end
