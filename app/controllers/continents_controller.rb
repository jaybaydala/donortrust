class ContinentsController < ApplicationController
  # GET /continents
  # GET /continents.xml
  def index
    @continents = Continent.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @continents.to_xml }
    end
  end

  # GET /continents/1
  # GET /continents/1.xml
  def show
    @continent = Continent.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @continent.to_xml }
    end
  end

  # GET /continents/new
  def new
    @continent = Continent.new
  end

  # GET /continents/1;edit
  def edit
    @continent = Continent.find(params[:id])
  end

  # POST /continents
  # POST /continents.xml
  def create
    @continent = Continent.new(params[:continent])

    respond_to do |format|
      if @continent.save
        flash[:notice] = 'Continent was successfully created.'
        format.html { redirect_to continent_url(@continent) }
        format.xml  { head :created, :location => continent_url(@continent) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @continent.errors.to_xml }
      end
    end
  end

  # PUT /continents/1
  # PUT /continents/1.xml
  def update
    @continent = Continent.find(params[:id])

    respond_to do |format|
      if @continent.update_attributes(params[:continent])
        flash[:notice] = 'Continent was successfully updated.'
        format.html { redirect_to continent_url(@continent) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @continent.errors.to_xml }
      end
    end
  end

  # DELETE /continents/1
  # DELETE /continents/1.xml
  def destroy
    @continent = Continent.find(params[:id])
    @continent.destroy

    respond_to do |format|
      format.html { redirect_to continents_url }
      format.xml  { head :ok }
    end
  end
end
