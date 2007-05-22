ActionController::Routing::Routes.draw do |map|
  map.resources :contacts, :active_scaffold => true

  map.resources :partner_statuses, :active_scaffold => true
  map.resources :partner_types, :active_scaffold => true 
  map.resources :partners, :active_scaffold => true do |partner|
    partner.resources :partner_histories, :active_scaffold => true
  end
  # hack around the active_scaffold's non-restful support of nesting
  map.resources :partner_histories, :active_scaffold => true
  map.resources :region_types
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Gather normal 'lookup' resources together.  Standard RESTful resources, no nesting
  map.resources :task_statuses, :active_scaffold => true
  map.resources :milestone_statuses
  map.resources :project_statuses
  #map.resources :task_categories, :active_scaffold => true, :path_prefix => "/admin"
  #map.resources :task_categories, :active_scaffold => true, :path_prefix => "/"
  map.resources :task_categories, :active_scaffold => true
  map.resources :milestone_categories
  map.resources :project_categories
  map.resources :partner_types
  map.resources :measure_categories
  
  #map.resources :partner_histories
    
  map.resources :programs
  map.resources :projects#, :path_prefix => "/programs/:program_id"
  map.resources :project_histories, :path_prefix => "/projects/:project_id"
  map.resources :milestones, :path_prefix => "/projects/:project_id"
  map.resources :milestone_histories, :path_prefix => "/milestones/:milestone_id"
  map.resources :tasks, :path_prefix => "/milestones/:milestone_id"
  map.resources :task_histories, :path_prefix => "/tasks/:task_id"
  map.resources :measures
  
  map.resources :continents, :active_scaffold => true 
  map.resources :countries, :active_scaffold => true #, :path_prefix => "/continents/:continent_id"
  map.resources :regions #, :path_prefix => "/countries/:country_id"
  map.resources :cities #, :path_prefix => "/regions/:region_id"
  map.resources :village_groups # , :path_prefix => "/regions/:region_id"
  map.resources :villages #, :path_prefix => "/village_groups/:village_group_id"
  
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
