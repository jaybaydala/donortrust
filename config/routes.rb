ActionController::Routing::Routes.draw do |map|

  map.resources :projects do |project|
    project.resources :project_histories
  end

  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
