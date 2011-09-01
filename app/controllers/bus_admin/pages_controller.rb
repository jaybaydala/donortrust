class BusAdmin::PagesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  
  active_scaffold :banner_images do |config|
    config.columns = [ :title, :permalink, :active, :content ]
    list.columns = [ :title, :permalink, :active ]
  end
  
  def index
    @pages = Page.all(:order => :lft)
  end
  
  def new
    @page = Page.new(params[:page])
  end

  def create
    @page = Page.new(params[:page])
    @saved = @page.save
    respond_to do |format|
      format.html {
        if @saved
          flash[:notice] = "The page has been saved"
          redirect_to bus_admin_pages_path
        else
          render :action => "new"
        end
      }
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    @saved = @page.update_attributes(params[:page])
    respond_to do |format|
      format.html {
        if @saved
          flash[:notice] = "The page has been saved"
          redirect_to bus_admin_pages_path
        else
          render :action => "edit"
        end
      }
    end
  end
  
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = "The page has been deleted"
        redirect_to bus_admin_pages_path
      }
    end
  end
end