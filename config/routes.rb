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

  #map.resources :tasks do |nested|
  #  nested.resources :task_histories
  #end

  map.resources :milestones do |nested|
    nested.resources :milestone_histories
    #nested.resources :tasks
  end

  map.resources :projects do |nested|
    nested.resources :project_histories
    nested.resources :milestones
  end

  map.resources :programs
  # map.resources :programs do |nested|
  #   nested.resource :projects
  # end

  map.resources :village_groups do |nested|
    nested.resources :villages
  end

  map.resources :regions do |nested|
    nested.resources :cities
    nested.resources :village_groups
  end
  # map.resources :cities
  # map.resources :villages

  map.resources :nations do |nested|
    nested.resources :regions
  end

  map.resources :continents do |nested|
    nested.resources :nations
  end

  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
