class Dt::PagesController < ApplicationController
  def show
    @page = Page.find_by_permalink(params[:id])
    @page = Page.find(params[:id]) unless @page
    redirect_to dt_upowered_path if @page.permalink == "upowered"
  end
end