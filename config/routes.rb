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

  map.resources :contacts

  map.resources :programs
  map.resources :projects#, :path_prefix => "/programs/:program_id"
  map.resources :project_histories, :path_prefix => "/projects/:project_id"
  map.resources :milestones, :path_prefix => "/projects/:project_id"
  map.resources :milestone_histories, :path_prefix => "/milestones/:milestone_id"

  map.resources :continents
  map.resources :nations, :path_prefix => "/continents/:continent_id"
  map.resources :regions, :path_prefix => "/nations/:nation_id"
  map.resources :cities, :path_prefix => "/regions/:region_id"
  map.resources :village_groups, :path_prefix => "/regions/:region_id"
  map.resources :villages, :path_prefix => "/village_groups/:village_group_id"

  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
