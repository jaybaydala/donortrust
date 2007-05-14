class ContactsController < ApplicationController
  before_filter :get_data
  
  # GET /contacts
  # GET /contacts.xml
  def index
    @contacts = Contact.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contacts.to_xml }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @contact.to_xml }
    end
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1;edit
  def edit
    @contact = Contact.find(params[:id])
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        format.html { redirect_to contact_url(@contact) }
        format.xml  { head :created, :location => contact_url(@contact) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors.to_xml }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact was successfully updated.'
        format.html { redirect_to contact_url(@contact) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors.to_xml }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.xml  { head :ok }
    end
  end
  
  def get_data
    @continents = Continent.find(:all)
    @countries = Country.find(:all)
    @regions = Region.find(:all)
    @cities = City.find(:all)
    @contact = Contacts.find(params[:id]) if params[:id] 
  end
end
