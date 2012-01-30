class Dt::SectorsController < ApplicationController
  
  layout "sectors"
  
  def show
    @sector = Sector.find(params[:id])
    @projects = @sector.projects
    @project = @projects.first
  end

end
