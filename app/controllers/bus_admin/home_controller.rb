class BusAdmin::HomeController < ApplicationController

  include BusAdmin::ProjectsHelper
  
  def index
    @total_projects = number_of_projects
    @all_projects = get_projects 
  end
  
end
