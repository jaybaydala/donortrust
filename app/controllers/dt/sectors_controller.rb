class Dt::SectorsController < ApplicationController
  
  layout "sectors"
  
  def show
    @sector = Sector.find(params[:id])
    @projects = @sector.projects
    @project = @projects.first
  end

  def like
    @sector = Sector.find(params[:id])
    params[:like] == "true" ? @sector.like(params[:network], @current_user) : @sector.unlike(params[:network], @current_user)
    render :json => {:likes_count => @sector.likes_count}
  end

end
