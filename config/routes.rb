ActionController::Routing::Routes.draw do |map|

  map.resources :frequency_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/frequency_types"

  # The priority is based upon order of creation: first created -> highest priority.
  
  #
  # RSS Feed Resources
  #
  map.resources :rss
  map.resources :rss_feed_elements, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rss_feed_elements"
  map.resources :rss_feeds, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rss_feeds"

  map.resources :home, :path_prefix => "/bus_admin", :controller => "bus_admin/home"

  map.resources :indicators, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/indicators"
  map.resources :targets, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/targets"

  map.resources :millennium_development_goals, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/millennium_development_goals"
  map.resources :sectors, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/sectors"

  #
  # Geographical Resources
  #
  map.resources :urban_centres, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/urban_centres"
  map.resources :village_groups, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/village_groups"
  map.resources :countries, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/countries"
  map.resources :villages, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/villages"
  map.resources :regions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/regions"

  map.resources :continents, :controller => 'bus_admin/continents', :active_scaffold => true, :path_prefix => '/bus_admin'
  map.resources :contacts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => 'bus_admin/contacts'

  map.resources :partner_statuses, :active_scaffold => true, :controller => "bus_admin/partner_statuses", :path_prefix => "/bus_admin"
  map.resources :partner_types, :active_scaffold => true, :controller => "bus_admin/partner_types", :path_prefix => "/bus_admin"
  map.resources :partners, :active_scaffold => true,  :path_prefix => '/bus_admin', :controller => 'bus_admin/partners' do |partner|
    #partner.resources :partner_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/partner_histories' 
  end
  map.resources :partner_versions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/partner_versions"

  # hack around the active_scaffold's non-restful support of nesting
  #map.resources :partner_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/partner_histories' 
  map.resources :region_types, :controller => "bus_admin/region_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true

  # Gather normal 'lookup' resources together.  Standard RESTful resources, no nesting
  map.resources :project_statuses, :controller => "bus_admin/project_statuses",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :milestone_statuses, :controller => "bus_admin/milestone_statuses", 
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :project_categories, :active_scaffold => true, :controller => "bus_admin/project_categories", :path_prefix => "/bus_admin" 
  map.resources :partner_types

  
  #map.resources :partner_histories
    
  map.resources :programs,    :controller => "bus_admin/programs",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :projects,    :controller => 'bus_admin/projects',
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :milestones,  :controller => "bus_admin/milestones",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :tasks,       :controller => "bus_admin/tasks",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
# do |project|
#    project.resources :project_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/project_histories'
#    project.resources :milestones, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/milestones'
#  end
#  map.resources :projects#, :active_scaffold => true #, :path_prefix => "/programs/:program_id"
#  map.resources :project_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/project_histories' 
#  map.resources :project_histories, :path_prefix => "/projects/:project_id"
  map.resources :measures
  
  #map.resources :regions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/regions"  #, :path_prefix => "/countries/:country_id"
 
  map.resources :villages #, :path_prefix => "/village_groups/:village_group_id"
  
  #easier routes for restful_authentication
  
  map.signup '/bus_admin/signup', :controller => 'bus_admin/bus_account', :action => 'signup'
  map.login '/bus_admin/login', :controller => 'bus_admin/bus_account', :action => 'login'
  map.logout '/bus_admin/logout', :controller => 'bus_admin/bus_account', :action => 'logout'
  map.index '/bus_admin/index', :controller => 'bus_admin/bus_account', :action => 'index'
  map.resources :bus_account, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_account"
  map.change_password '/bus_admin/change_password', :controller => 'bus_admin/bus_account', :action =>'change_password'
  map.show_encryption '/bus_admin/bus_account/show_encryption', :controller =>'bus_admin/bus_account',:action =>'show_encryption'
  map.change_password_now '/bus_admin/bus_account/change_password_now', :controller => 'bus_admin/bus_account', :action =>'change_password_now'
  #map.display_pending '/bus_admin/display_pending', :controller => 'bus_admin/partners', :action =>'display_pending'
  map.home '/bus_admin/index', :controller => 'bus_admin/home', :action=> 'index'
  map.report 'bus_admin/report', :controller => 'bus_admin/projects', :action => 'report'
  map.report 'bus_admin/individual_report', :controller => 'bus_admin/projects', :action => 'individual_report'
  map.report 'bus_admin/report_partners', :controller => 'bus_admin/partners', :action => 'report_partners'
  map.report 'bus_admin/individual_report_partners', :controller => 'bus_admin/partners', :action => 'individual_report_partners'
  map.export_to_csv 'bus_admin/export_to_csv', :controller => 'bus_admin/projects', :action => 'export_to_csv'
  
  # front-end resources - non-admin
  map.resources :projects, :controller=> 'dt/projects', :name_prefix => 'dt_', :path_prefix => '/dt', :collection => { :search => :get }, :member => { :project => :get, :village => :get, :nation => :get, :community => :get }
  #map.resources :users, :controller=> 'dt/users', :name_prefix => 'dt_', :path_prefix => '/dt'
  #map.resources :groups, :controller=> 'dt/groups', :name_prefix => 'dt_', :path_prefix => '/dt'

  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
  map.connect "*anything",
              :controller => 'dt/projects'
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
