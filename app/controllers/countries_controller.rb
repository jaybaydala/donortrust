class CountriesController < ApplicationController
  before_filter:get_data

  # GET /countries
  # GET /countries.xml
  def index
    @countries = Country.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @countries.to_xml }
    end
  end

  # GET /countries/1
  # GET /countries/1.xml
  def show
    @country = Country.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @country.to_xml }
    end
  end

  # GET /countries/new
  def new
    @country = Country.new
  end

  # GET /countries/1;edit
  def edit
    @country = Country.find(params[:id])
  end

  # POST /countries
  # POST /countries.xml
  def create
    @country = Country.new(params[:country])

    respond_to do |format|
      if @country.save
        flash[:notice] = 'Country was successfully created.'
        format.html { redirect_to country_url(@country) }
        format.xml  { head :created, :location => country_url(@country) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @country.errors.to_xml }
      end
    end
  end

  # PUT /countries/1
  # PUT /countries/1.xml
  def update
    @country = Country.find(params[:id])

    respond_to do |format|
      if @country.update_attributes(params[:country])
        flash[:notice] = 'Country was successfully updated.'
        format.html { redirect_to country_url(@country) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @country.errors.to_xml }
      end
    end
  end

  # DELETE /countries/1
  # DELETE /countries/1.xml
  def destroy
    @country = Country.find(params[:id])
    @country.destroy

    respond_to do |format|
      format.html { redirect_to countries_url }
      format.xml  { head :ok }
    end
  end
   def get_data
    @continents = Continent.find(:all)

  end
  
end
