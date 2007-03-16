class MeasuresController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @measure_pages, @measures = paginate :measures, :per_page => 10
  end

  def show
    @measure = Measure.find(params[:id])
  end

  def new
    @measure = Measure.new
  end

  def create
    @measure = Measure.new(params[:measure])
    if @measure.save
      flash[:notice] = 'Measure was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @measure = Measure.find(params[:id])
  end

  def update
    @measure = Measure.find(params[:id])
    if @measure.update_attributes(params[:measure])
      flash[:notice] = 'Measure was successfully updated.'
      redirect_to :action => 'show', :id => @measure
    else
      render :action => 'edit'
    end
  end

  def destroy
    Measure.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
