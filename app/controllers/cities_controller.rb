class CitiesController < ApplicationController
  before_filter :get_data
  # GET /cities
  # GET /cities.xml
  def index
    @cities = City.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @cities.to_xml }
    end
  end

  # GET /cities/1
  # GET /cities/1.xml
  def show
    @city = City.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @city.to_xml }
    end
  end

  # GET /cities/new
  def new
    @city = City.new
  end

  # GET /cities/1;edit
  def edit
    @city = City.find(params[:id])
  end

  # POST /cities
  # POST /cities.xml
  def create
    @city = City.new(params[:city])

    respond_to do |format|
      if @city.save
        flash[:notice] = 'City was successfully created.'
        format.html { redirect_to city_url(@city) }
        format.xml  { head :created, :location => city_url(@city) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @city.errors.to_xml }
      end
    end
  end

  # PUT /cities/1
  # PUT /cities/1.xml
  def update
    @city = City.find(params[:id])

    respond_to do |format|
      if @city.update_attributes(params[:city])
        flash[:notice] = 'City was successfully updated.'
        format.html { redirect_to city_url(@city) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @city.errors.to_xml }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.xml
  def destroy
    @city = City.find(params[:id])
    @city.destroy

    respond_to do |format|
      format.html { redirect_to cities_url }
      format.xml  { head :ok }
    end
  end
  
   def get_data
    @regions = Region.find(:all)

  end
end
