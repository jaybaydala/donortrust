ActionController::Routing::Routes.draw do |map|
  map.resources :village_groups, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/village_groups"

  map.resources :cities, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/cities"

  map.resources :countries, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/countries"

  map.resources :villages, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/villages"

  map.resources :regions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/regions"

  map.resources :nations, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/nations"

  map.resources :projects, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => 'bus_admin/projects'
  
  map.resources :continents, :controller => 'bus_admin/continents', :active_scaffold => true, :path_prefix => '/bus_admin'

  map.resources :contacts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => 'bus_admin/contacts'

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
  map.resources :project_statuses
  map.resources :milestone_statuses, :controller => "bus_admin/milestone_statuses", 
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :task_statuses, :controller => "bus_admin/task_statuses", 
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :task_categories, :controller => "bus_admin/task_categories",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :milestone_categories
  map.resources :project_categories
  map.resources :partner_types
  map.resources :measure_categories, :controller => "bus_admin/measure_categories",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true

  
  #map.resources :partner_histories
    
  map.resources :programs, :active_scaffold => true
  map.resources :projects#, :path_prefix => "/programs/:program_id"
  map.resources :project_histories, :path_prefix => "/projects/:project_id"
  map.resources :milestones, :path_prefix => "/projects/:project_id"
  map.resources :milestone_histories, :path_prefix => "/milestones/:milestone_id"
  #map.resources :tasks, :path_prefix => "/milestones/:milestone_id"
  map.resources :tasks, :controller => "bus_admin/tasks", :active_scaffold => true,
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin/milestones/:milestone_id"
  map.resources :task_histories, :path_prefix => "/tasks/:task_id"
  map.resources :measures
  
  map.resources :continents, :active_scaffold => true 
  map.resources :countries, :active_scaffold => true #, :path_prefix => "/continents/:continent_id"
  map.resources :regions #, :path_prefix => "/countries/:country_id"
 
  map.resources :village_groups # , :path_prefix => "/regions/:region_id"
  map.resources :villages #, :path_prefix => "/village_groups/:village_group_id"
  
  # front-end resources - non-admin
  map.resource :dt do |dt|
    dt.resources :projects, :name_prefix => 'dt_', :controller=> 'dt/projects'
    #dt.resources :accounts, :name_prefix => 'dt_', :controller=> 'dt/accounts'
    #dt.resources :groups, :name_prefix => 'dt_', :controller=> 'dt/groups'
  end
  
  #easier routes for restful_authentication
  
  map.signup '/bus_admin/signup', :controller => 'bus_admin/bus_account', :action => 'signup'
  map.login '/bus_admin/login', :controller => 'bus_admin/bus_account', :action => 'login'
  map.logout '/bus_admin/logout', :controller => 'bus_admin/bus_account', :action => 'logout'
  map.index '/bus_admin/index', :controller => 'bus_admin/bus_account', :action => 'index'
  map.resources :bus_account, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_account"
  map.change_password '/bus_admin/change_password', :controller => 'bus_admin/bus_account', :action =>'change_password'
  map.show_encryption '/bus_admin/bus_account/show_encryption', :controller =>'bus_admin/bus_account',:action =>'show_encryption'
  map.change_password_now '/bus_admin/bus_account/change_password_now', :controller => 'bus_admin/bus_account', :action =>'change_password_now'
  
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
