ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Gather normal 'lookup' resources together.  Standard RESTful resources, no nesting
  map.resources :partner_statuses
  map.resources :milestone_statuses
  map.resources :project_statuses
  map.resources :statuses # to be deleted once milestones updated
  map.resources :milestone_categories
  map.resources :project_categories
  map.resources :partner_types

  map.resources :partners

  map.resources :programs

  map.resources :contacts

  map.resources :milestones do |milestone|
    milestone.resources :milestone_histories
  end

  map.resources :projects do |project|
    project.resources :project_histories
  end

  map.resources :continents do |continent|
    continent.resources :nations
  end

  map.resources :nations do |nation|
    nation.resources :regions
  end

  map.resources :regions do |region|
    region.resources :cities
    region.resources :village_groups
  end

  #  map.resources :cities

  map.resources :village_groups do |village_group|
    village_group.resources :villages
  end

  map.resources :villages

  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
