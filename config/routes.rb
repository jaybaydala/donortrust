ActionController::Routing::Routes.draw do |map|
  map.resources :comments, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/comments"
  map.feedback 'bus_admin/feedback', :controller => 'bus_admin/comments', :action => 'feedback'        
 
  # front-end resources - non-admin
  map.resources :projects, :controller => 'dt/projects', :name_prefix => 'dt_', :path_prefix => '/dt', :member => { :specs => :get } do |project|
    project.resources :villages, :controller => 'dt/villages', :name_prefix => 'dt_'
    project.resources :nations, :controller => 'dt/nations', :name_prefix => 'dt_'
    project.resources :communities, :controller => 'dt/communities', :name_prefix => 'dt_'
    project.resources :investments, :controller => 'dt/investments', :name_prefix => 'dt_', :path_prefix => '/dt', :collection => { :confirm => :post }
  end
  map.resource :search, :controller => 'dt/search', :name_prefix => 'dt_', :path_prefix => '/dt'
  map.resources :accounts, :controller => 'dt/accounts', :name_prefix => 'dt_', :path_prefix => '/dt', 
    :collection => { :activate => :get, :resend => :get } do |account|
    account.resources :deposits, :controller => 'dt/deposits', :name_prefix => 'dt_', :collection => { :confirm => :post }
  end
  map.resource :session, :controller => 'dt/sessions', :name_prefix => 'dt_', :path_prefix => '/dt'
  map.dt_signup '/signup', :controller => 'dt/accounts', :action => 'new'
  map.dt_login  '/login',  :controller => 'dt/sessions', :action => 'new'
  map.dt_logout '/logout', :controller => 'dt/sessions', :action => 'destroy'
  map.resources :gifts, :controller => 'dt/gifts', :name_prefix => 'dt_', :path_prefix => '/dt', 
    :collection => { :confirm => :post, :open => :get, :preview => :get },
    :member => { :unwrap => :put }
  map.resources :groups, :controller=> 'dt/groups', :name_prefix => 'dt_', :path_prefix => '/dt'

  map.resources :memberships, 
  	:controller=> 'dt/memberships', 
  	:name_prefix => 'dt_',
  	:path_prefix => '/dt',
  	:member => { :bestow => :post }

  map.resources :memberships, 
  	:controller=> 'dt/memberships', 
  	:new => { :join => :put },
  	:name_prefix => 'dt_groups_messages', 
  	:path_prefix => '/dt/groups/:group_id'
    
  #map.resources :memberships, 
  	#:controller=> 'dt/memberships', 
  	#:name_prefix => 'dt_', 
  	#:path_prefix => '/dt/groups/:group_id', 
  	#:member => { :swa => :post }

  # inactive_record resources
  map.inactive_records 'bus_admin/milestone_statuses/inactive_records', :controller => 'bus_admin/milestone_statuses', :action => 'inactive_records'
  map.recover_record 'bus_admin/milestone_statuses/recover_record', :controller => 'bus_admin/milestone_statuses', :action => 'recover_record'
  map.inactive_records 'bus_admin/project_statuses/inactive_records', :controller => 'bus_admin/project_statuses', :action => 'inactive_records'
  map.recover_record 'bus_admin/project_statuses/recover_record', :controller => 'bus_admin/project_statuses', :action => 'recover_record'
  map.inactive_records 'bus_admin/partner_statuses/inactive_records', :controller => 'bus_admin/partner_statuses', :action => 'inactive_records'
  map.recover_record 'bus_admin/partner_statuses/recover_record', :controller => 'bus_admin/partner_statuses', :action => 'recover_record'
  map.inactive_records 'bus_admin/frequency_types/inactive_records', :controller => 'bus_admin/frequency_types', :action => 'inactive_records'
  map.recover_record 'bus_admin/frequency_types/recover_record', :controller => 'bus_admin/frequency_types', :action => 'recover_record'
  map.inactive_records 'bus_admin/sectors/inactive_records', :controller => 'bus_admin/sectors', :action => 'inactive_records'
  map.recover_record 'bus_admin/sectors/recover_record', :controller => 'bus_admin/sectors', :action => 'recover_record'
  map.inactive_records 'bus_admin/group_types/inactive_records', :controller => 'bus_admin/group_types', :action => 'inactive_records'
  map.recover_record 'bus_admin/group_types/recover_record', :controller => 'bus_admin/group_types', :action => 'recover_record'
  map.inactive_records 'bus_admin/partner_types/inactive_records', :controller => 'bus_admin/partner_types', :action => 'inactive_records'
  map.recover_record 'bus_admin/partner_types/recover_record', :controller => 'bus_admin/partner_types', :action => 'recover_record'
  map.inactive_records 'bus_admin/millennium_goals/inactive_records', :controller => 'bus_admin/millennium_goals', :action => 'inactive_records'
  map.recover_record 'bus_admin/millennium_goals/recover_record', :controller => 'bus_admin/millennium_goals', :action => 'recover_record'
  map.inactive_records 'bus_admin/indicators/inactive_records', :controller => 'bus_admin/indicators', :action => 'inactive_records'
  map.recover_record 'bus_admin/indicators/recover_record', :controller => 'bus_admin/indicators', :action => 'recover_record'
  map.inactive_records 'bus_admin/targets/inactive_records', :controller => 'bus_admin/targets', :action => 'inactive_records'
  map.recover_record 'bus_admin/targets/recover_record', :controller => 'bus_admin/targets', :action => 'recover_record'
  
  # bus_admin resources
  map.resources :indicator_measurements, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/indicator_measurements"
  map.resources :bus_security_levels, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_security_levels"
  map.resources :bus_user_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_user_types"
  map.resources :bus_secure_actions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_secure_actions"
  map.resources :bus_security_levels, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_security_levels"
  map.resources :measurements, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/measurements"
  map.resources :users, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/users"

  # The priority is based upon order of creation: first created -> highest priority.
  
  #
  # RSS Feed Resources
  #
  map.resources :rss
  map.resources :rss_feed_elements, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rss_feed_elements"
  map.resources :rss_feeds, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rss_feeds"

  #
  # Media Resources Specifically You Tube and Flickr Resources
  #
  #
  # take that REST
  map.resources :you_tube_videos,         :path_prefix => "/bus_admin", :controller => "bus_admin/you_tube_videos",         :collection => {:preview => :post, 
                                                                                                                                              :search => :post,
                                                                                                                                              :search_by_tag => :post, 
                                                                                                                                              :search_by_user => :post, 
                                                                                                                                              :search_by_category_and_tag => :post, 
                                                                                                                                              :list_by_featured => :post, 
                                                                                                                                              :list_by_popular => :post,
                                                                                                                                              :show_video => :post,
                                                                                                                                              :edit_video => :post,
                                                                                                                                              :remove => :post,
                                                                                                                                              :add => :post
                                                                                                                                           }
  map.resources :project_you_tube_videos, :path_prefix => "/bus_admin", :controller => "bus_admin/project_you_tube_videos", :collection => {  :add => :post, 
                                                                                                                                              :remove => :post, 
                                                                                                                                              :search => :post, 
                                                                                                                                              :projects => :post, 
                                                                                                                                              :videos => :post,
                                                                                                                                            }
  map.resources :flickr_images, :path_prefix => "/bus_admin", :controller => "bus_admin/flickr_images",                     :collection => {  :search => :post, 
                                                                                                                                              :add => :post, 
                                                                                                                                              :show_flickr => :post, 
                                                                                                                                              :show_db_flickr => :post, 
                                                                                                                                              :remove => :post, 
                                                                                                                                              :photos=>:post }
                                                                                                                                              
  map.resources :project_flickr_images, :path_prefix => "/bus_admin", :controller => "bus_admin/project_flickr_images", :collection => {      :add => :post, 
                                                                                                                                              :remove => :post, 
                                                                                                                                              :search => :post, 
                                                                                                                                              :projects => :post, 
                                                                                                                                            }
  map.resources :welcome, :path_prefix => "/bus_admin", :controller => "bus_admin/welcome"
  map.resources :home, :path_prefix => "/bus_admin", :controller => "bus_admin/home"

  map.resources :indicators, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/indicators"
  map.resources :targets, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/targets"

  map.resources :millennium_goals, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/millennium_goals"
  map.resources :sectors, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/sectors"

  #
  # Geographical Resources
  #
  map.resources :continents, :controller => 'bus_admin/continents', :active_scaffold => true, :path_prefix => '/bus_admin'
  map.resources :countries, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/countries"
  map.resources :regions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/regions"
  #map.resources :regions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/regions"  #, :path_prefix => "/countries/:country_id"
  map.resources :urban_centres, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/urban_centres"
#  map.resources :village_groups, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/village_groups"
  map.resources :villages, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/villages"
  map.resources :villages #, :path_prefix => "/village_groups/:village_group_id"

  map.resources :country_sectors, :controller => "bus_admin/country_sectors",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true

  #
  # Contacts
  # 
  map.resources :contacts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => 'bus_admin/contacts'
  map.populate_contact_countries '/bus_admin/contacts/populate_contact_countries', :controller => 'bus_admin/contacts', :action =>'populate_contact_countries'
  map.populate_contact_regions '/bus_admin/contacts/populate_contact_regions', :controller => 'bus_admin/contacts', :action =>'populate_contact_regions'
  map.populate_contact_urban_centres '/bus_admin/contacts/populate_contact_urban_centres', :controller => 'bus_admin/contacts', :action =>'populate_contact_urban_centres'  

  map.resources :partners, :active_scaffold => true,  :path_prefix => '/bus_admin', :controller => 'bus_admin/partners' do |partner|
    #partner.resources :partner_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/partner_histories' 
  end
  map.resources :partner_versions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/partner_versions"
  #map.resources :partner_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/partner_histories' 
  #map.resources :partner_histories

  #
  # Gather normal 'lookup' resources together.  Standard RESTful resources, no nesting
  #
  map.resources :project_statuses, :controller => "bus_admin/project_statuses",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :milestone_statuses, :controller => "bus_admin/milestone_statuses", 
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :frequency_types, :controller => "bus_admin/frequency_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :partner_statuses, :controller => "bus_admin/partner_statuses",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :partner_types, :controller => "bus_admin/partner_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :region_types, :controller => "bus_admin/region_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :group_types, :controller => "bus_admin/group_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
    
  map.resources :programs,    :controller => "bus_admin/programs",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :projects,    :controller => 'bus_admin/projects',
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :milestones,  :controller => "bus_admin/milestones",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  #map.resources :milestone_versions, :controller => "bus_admin/milestone_versions",
  #  :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :tasks,       :controller => "bus_admin/tasks",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :task_versions, :controller => "bus_admin/task_versions",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
#  map.resources :project_histories, :active_scaffold => true, :path_prefix => '/bus_admin', :controller => 'bus_admin/project_histories' 
#  map.resources :project_histories, :path_prefix => "/projects/:project_id"
  map.resources :measures
  map.resources :accounts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/accounts"
  map.resources :groups, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/groups"

  #easier routes for restful_authentication
  map.bob '/bus_admin/bob', :controller => 'bus_admin/project_statuses', :action => 'bob'
  map.signup '/bus_admin/signup', :controller => 'bus_admin/bus_account', :action => 'signup'
  map.login '/bus_admin/login', :controller => 'bus_admin/bus_account', :action => 'login'
  map.logout '/bus_admin/logout', :controller => 'bus_admin/bus_account', :action => 'logout'
  map.index '/bus_admin/index', :controller => 'bus_admin/bus_account', :action => 'index'
  map.get_actions '/bus_admin/bus_user_types/get_actions', :controller => 'bus_admin/bus_user_types', :action =>'get_actions'
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
  map.display_inline_report 'bus_admin/display_inline_report', :controller => 'bus_admin/projects', :action => 'display_inline_report'
  map.report 'bus_admin/individual_report_inline', :controller => 'bus_admin/projects', :action => 'individual_report_inline'
  map.note 'bus_admin/show_note', :controller => 'bus_admin/partners', :action => 'show_note'
  map.note_project 'bus_admin/show_project_note', :controller => 'bus_admin/projects', :action => 'show_project_note'
  map.note_program 'bus_admin/show_program_note', :controller => 'bus_admin/programs', :action => 'show_program_note'
  map.reset_password 'bus_admin/reset_password', :controller => 'bus_admin/bus_account', :action => 'reset_password'
  map.reset_password_now 'bus_admin/reset_password_now', :controller => 'bus_admin/bus_account', :action => 'reset_password_now'
  map.request_temporary_password 'bus_admin/request_temporary_password', :controller => 'bus_admin/bus_account', :action => 'request_temporary_password'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect '', :controller => 'bus_admin/bus_account', :action => 'login'
  # Install the default route as the lowest priority.
  #map.connect "*anything",
  #            :controller => 'dt/projects'
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
#  map.connect ':controller/:action/:id'
end
