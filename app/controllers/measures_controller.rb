class MeasuresController < ApplicationController
  # GET /measures
  # GET /measures.xml
  def index
    @measures = Measure.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @measures.to_xml }
    end
  end

  # GET /measures/1
  # GET /measures/1.xml
  def show
    @measure = Measure.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @measure.to_xml }
    end
  end

  # GET /measures/new
  def new
    @measure = Measure.new
  end

  # GET /measures/1;edit
  def edit
    @measure = Measure.find(params[:id])
  end

  # POST /measures
  # POST /measures.xml
  def create
    @measure = Measure.new(params[:measure])

    respond_to do |format|
      if @measure.save
        flash[:notice] = 'Measure was successfully created.'
        format.html { redirect_to measure_url(@measure) }
        format.xml  { head :created, :location => measure_url(@measure) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @measure.errors.to_xml }
      end
    end
  end

  # PUT /measures/1
  # PUT /measures/1.xml
  def update
    @measure = Measure.find(params[:id])

    respond_to do |format|
      if @measure.update_attributes(params[:measure])
        flash[:notice] = 'Measure was successfully updated.'
        format.html { redirect_to measure_url(@measure) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measure.errors.to_xml }
      end
    end
  end

  # DELETE /measures/1
  # DELETE /measures/1.xml
  def destroy
    @measure = Measure.find(params[:id])
    @measure.destroy

    respond_to do |format|
      format.html { redirect_to measures_url }
      format.xml  { head :ok }
    end
  end
end
