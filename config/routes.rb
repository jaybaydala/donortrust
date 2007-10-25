ActionController::Routing::Routes.draw do |map|
 
  map.resources :projects, :controller => 'dt/projects', :name_prefix => 'dt_', :path_prefix => '/dt', :member => { :details => :get, :community => :get, :nation => :get, :organization => :get, :connect => :get, :facebook_login => :get, :timeline => :get } do |project|
    project.resources :investments, :controller => 'dt/investments', :name_prefix => 'dt_', :path_prefix => '/dt', :collection => { :confirm => :post }
  end
  map.resources :place_searches, :controller => 'dt/place_searches', :name_prefix => 'dt_', :path_prefix => '/dt'
  map.resource :search, :controller => 'dt/search', :name_prefix => 'dt_', :path_prefix => '/dt'
  map.resources :accounts, :controller => 'dt/accounts', :name_prefix => 'dt_', :path_prefix => '/dt', :collection => { :activate => :get, :resend => :get } do |account|
    account.resources :deposits, :controller => 'dt/deposits', :name_prefix => 'dt_', :collection => { :confirm => :post }
    account.resources :my_wishlists, :controller => 'dt/my_wishlists', :name_prefix => 'dt_'
    account.resources :tax_receipts, :controller => 'dt/tax_receipts', :name_prefix => 'dt_'
    account.resources :account_memberships, :controller => 'dt/account_memberships', :name_prefix => 'dt_'
  end
  map.resource :session, :controller => 'dt/sessions', :name_prefix => 'dt_', :path_prefix => '/dt'
  map.dt_signup '/dt/signup', :controller => 'dt/accounts', :action => 'new'
  map.dt_login  '/dt/login',  :controller => 'dt/sessions', :action => 'new'
  map.dt_logout '/dt/logout', :controller => 'dt/sessions', :action => 'destroy'
  map.resources :gifts, :controller => 'dt/gifts', :name_prefix => 'dt_', :path_prefix => '/dt', :collection => { :confirm => :post, :open => :get, :preview => :get }, :member => { :unwrap => :put }
  map.resources :groups, :controller=> 'dt/groups', :name_prefix => 'dt_', :path_prefix => '/dt' do |group|
    group.resources :memberships, :controller => 'dt/memberships', :name_prefix => 'dt_', :collection => { :typify => :put }
    group.resources :group_projects, :controller => 'dt/group_projects', :name_prefix => 'dt_'
    group.resources :group_news, :controller => 'dt/group_news', :name_prefix => 'dt_'
    group.resources :group_invitations, :controller => 'dt/group_invitations', :name_prefix => 'dt_'
  end
  map.resources :wishlists, :controller=> 'dt/wishlists', :name_prefix => 'dt_', :path_prefix => '/dt'
  map.resources :tell_friends, :controller=> 'dt/tell_friends', :name_prefix => 'dt_', :path_prefix => '/dt', :collection => { :confirm => :post, :preview => :get }
  map.connect '/dt', :controller => 'dt/projects'

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
  map.recover_record 'bus_admin/measures/recover_record', :controller => 'bus_admin/measures', :action => 'recover_record'
  map.inactive_records 'bus_admin/measures/inactive_records', :controller => 'bus_admin/measures', :action => 'inactive_records'
   map.inactive_records 'bus_admin/causes/inactive_records', :controller => 'bus_admin/causes', :action => 'inactive_records'
  map.recover_record 'bus_admin/causes/recover_record', :controller => 'bus_admin/causes', :action => 'recover_record'
 
  # bus_admin resources

  map.resources :gifts,  :path_prefix => "/bus_admin", :controller => "bus_admin/gifts", :collection => {:unwrap => :post}
  map.resources :banner_images, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/banner_images"
  map.resources :rank_values, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rank_values"
  map.resources :load,  :path_prefix => "/bus_admin", :controller => "bus_admin/load", :collection => {:loads => :post}
  map.resources :budget_items, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/budget_items"
  map.resources :financial_sources, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/financial_sources"
  map.resources :collaborating_agencies, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/collaborating_agencies"
  map.resources :e_cards, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/e_cards"
  map.resources :places, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/places"
  map.resources :place_sectors, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/place_sectors"
  map.populate_project_places '/bus_admin/projects/populate_project_places', :controller => 'bus_admin/projects', :action => 'populate_project_places'
  map.resources :ranks, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/ranks"
  map.resources :quick_fact_partners, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/quick_fact_partners"
  map.resources :quick_fact_groups, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/quick_fact_groups"
  map.resources :quick_fact_sectors, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/quick_fact_sectors"
  map.resources :quick_fact_places, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/quick_fact_places"
  map.resources :quick_facts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/quick_facts"
  map.resources :comments, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/comments"
  map.feedback 'bus_admin/feedback', :controller => 'bus_admin/comments', :action => 'feedback'        
  
  map.resources :key_measures, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measures"
  map.resources :key_measures, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measures"
  map.resources :key_measure_datas, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measure_datas"
  map.resources :key_measure_datas, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measure_datas"
  map.resources :key_measure_datas, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measure_datas"
  
  map.resources :key_measures, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measures"
  map.resources :bus_security_levels, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_security_levels"
  map.resources :bus_user_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_user_types"
  map.resources :bus_secure_actions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_secure_actions"
  map.resources :bus_security_levels, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_security_levels"
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
                                                                                                                                              :show_flickr => :post, 
                                                                                                                                              :show_db_flickr => :post,
                                                                                                                                              :photos=>:post }
                                                                                                                                            
  map.resources :welcome, :path_prefix => "/bus_admin", :controller => "bus_admin/welcome"
  map.resources :home, :path_prefix => "/bus_admin", :controller => "bus_admin/home"

  map.resources :measures, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/measures"

  map.resources :millennium_goals, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/millennium_goals"
  map.resources :sectors, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/sectors"
  map.resources :causes, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/causes"

  #
  # Geographical Resources
  #
  map.resources :places, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/places"

  #
  # Contacts
  # 
  map.resources :contacts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => 'bus_admin/contacts'
  map.populate_contact_places '/bus_admin/contacts/populate_contact_places', :controller => 'bus_admin/contacts', :action => 'populate_contact_places'
  map.resources :partners, :active_scaffold => true,  :path_prefix => '/bus_admin', :controller => 'bus_admin/partners'

  #
  # Gather normal 'lookup' resources together.  Standard RESTful resources, no nesting
  #
  map.resources :project_statuses, :controller => "bus_admin/project_statuses",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
 
  map.populate_project_places '/bus_admin/projects/populate_project_places', :controller => 'bus_admin/projects', :action => 'populate_project_places'
    
  map.populate_place_sector_places '/bus_admin/projects/populate_place_sector_places', :controller => 'bus_admin/place_sectors', :action => 'populate_place_sector_places'
   
  map.resources :milestone_statuses, :controller => "bus_admin/milestone_statuses", 
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :frequency_types, :controller => "bus_admin/frequency_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :partner_statuses, :controller => "bus_admin/partner_statuses",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :partner_types, :controller => "bus_admin/partner_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :group_types, :controller => "bus_admin/group_types",
    :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true
  map.resources :place_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/place_types"
  map.resources :rank_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rank_types"
  map.resources :quick_fact_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/quick_fact_types"
  map.resources :banner_images, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/banner_images"
  map.resources :rank_values, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rank_values"

  map.resources :programs,    :controller => "bus_admin/programs",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :projects,    :controller => 'bus_admin/projects',
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :milestones,  :controller => "bus_admin/milestones",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :tasks,       :controller => "bus_admin/tasks",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
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
  map.byProject 'bus_admin/_timeline_json', :controller => 'bus_admin/projects', :action => 'byProject'
  map.byProject 'bus_admin/_showProjectTimeline', :controller => 'bus_admin/projects', :action => 'showProjectTimeline'
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
  map.connect '/bus_admin', :controller => 'bus_admin/home'
  # Install the default route as the lowest priority.
  #map.connect "*anything",
  #            :controller => 'dt/projects'
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
#  map.connect ':controller/:action/:id'
end
