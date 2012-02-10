class Dt::PagesController < DtApplicationController
  def show
    @page = Page.find_by_permalink(params[:id])
    find_page_by_path if params[:path].present?
    @page = Page.find(params[:id]) unless @page
    redirect_to dt_upowered_path if @page.permalink == "upowered"
    render :action => (@page.template.present? ? @page.template : 'show'), :layout => (@page.layout.present? ? @page.layout : 'application')
  end

  protected
    def find_page_by_path
      @page = Page.find_by_path(params[:path].join('/'))
    end
end