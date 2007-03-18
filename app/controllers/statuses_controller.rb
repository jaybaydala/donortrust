class StatusesController < ApplicationController
  # GET /statuses
  # GET /statuses.xml
  def index
    @statuses = Status.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @statuses.to_xml }
    end
  end

  # GET /statuses/1
  # GET /statuses/1.xml
  def show
    @status = Status.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @status.to_xml }
    end
  end

  # GET /statuses/new
  def new
    @status = Status.new
  end

  # GET /statuses/1;edit
  def edit
    @status = Status.find(params[:id])
  end

  # POST /statuses
  # POST /statuses.xml
  def create
    @status = Status.new(params[:status])

    respond_to do |format|
      if @status.save
        flash[:notice] = 'Status was successfully created.'
        format.html { redirect_to status_url(@status) }
        format.xml  { head :created, :location => status_url(@status) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @status.errors.to_xml }
      end
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.xml
  def update
    @status = Status.find(params[:id])

    respond_to do |format|
      if @status.update_attributes(params[:status])
        flash[:notice] = 'Status was successfully updated.'
        format.html { redirect_to status_url(@status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @status.errors.to_xml }
      end
    end
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.xml
  def destroy
    @status = Status.find(params[:id])
    @status.destroy

    respond_to do |format|
      format.html { redirect_to statuses_url }
      format.xml  { head :ok }
    end
  end
end
