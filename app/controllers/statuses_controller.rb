class StatusesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @status_pages, @statuses = paginate :statuses, :per_page => 10
  end

  def show
    @status = Status.find(params[:id])
  end

  def new
    @status = Status.new
  end

  def create
    @status = Status.new(params[:status])
    if @status.save
      flash[:notice] = 'Status was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @status = Status.find(params[:id])
  end

  def update
    @status = Status.find(params[:id])
    if @status.update_attributes(params[:status])
      flash[:notice] = 'Status was successfully updated.'
      redirect_to :action => 'show', :id => @status
    else
      render :action => 'edit'
    end
  end

  def destroy
    Status.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
