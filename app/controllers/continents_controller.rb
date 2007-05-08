class ContinentsController < ApplicationController
  # GET /continents
  # GET /continents.xml
  def index
   # @continents = Continent.find(:all)
    @continent_pages, @continents = paginate(:continents, :order => 'continent_name')
   # logger.info('index')

   respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @continents.to_xml }
      format.js 
    end
  end
  
  def continents_list
    @continent_pages, @continents = paginate(:continents => 'continent_name')
    
  end

  # GET /continents/1
  # GET /continents/1.xml
  def show
    @continent = Continent.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @continent.to_xml }
      format.js {render :action => 'create.rjs'}
    end
  end

  # GET /continents/new
 # def new
 #   @continent = Continent.new
   
#  end

  # GET /continents/1;edit
  def edit
    @continent = Continent.find(params[:id])
     
    respond_to do |format|
      format.js {render :action => 'edit.rjs'}
    end 
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
        format.js {render :action => 'create.rjs'}
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
  
  respond_to do |wants|
      wants.html { redirect_to continents_url}
      wants.js { render :action => "delete.rjs" }
    end
   
  end
end
