class ProgramsController < ApplicationController

  before_filter :get_contacts 

  # GET /programs
  # GET /programs.xml
  def index
    @programs = Program.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @programs.to_xml }
    end
  end

  # GET /programs/1
  # GET /programs/1.xml
  def show
    @programs = Program.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @programs.to_xml }
    end
  end

  # GET /programs/new
  def new
    @programs = Program.new
  end

  # GET /programs/1;edit
  def edit
    @programs = Program.find(params[:id])
  end

  # POST /programs
  # POST /programs.xml
  def create
    @programs = Program.new(params[:program])

    respond_to do |format|
      if @programs.save
        flash[:notice] = 'Programs was successfully created.'
        format.html { redirect_to program_url(@programs) }
        format.xml  { head :created, :location => program_url(@programs) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @programs.errors.to_xml }
      end
    end
  end

  # PUT /programs/1
  # PUT /programs/1.xml
  def update
    @programs = Program.find(params[:id])

    respond_to do |format|
      if @programs.update_attributes(params[:program])
        flash[:notice] = 'Programs was successfully updated.'
        format.html { redirect_to program_url(@programs) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @programs.errors.to_xml }
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.xml
  def destroy
    @programs = Program.find(params[:id])
    @programs.destroy

    respond_to do |format|
      format.html { redirect_to program_url }
      format.xml  { head :ok }
    end
  end
  
  def get_contacts
    @contacts = Contact.find(:all)
  end
end
