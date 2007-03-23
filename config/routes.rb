ActionController::Routing::Routes.draw do |map|
  map.resources :partner_statuses

  map.resources :partners

  map.resources :partner_types

  # The priority is based upon order of creation: first created -> highest priority.

  map.resources :contacts

  map.resources :statuses

  map.resources :milestones do |milestone|
    milestone.resources :milestone_histories
  end

  map.resources :projects do |project|
    project.resources :project_histories
  end
  
  map.resources :project_statuses
  
  map.resources :project_categories

  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
