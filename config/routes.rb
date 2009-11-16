ActionController::Routing::Routes.draw do |map|
  map.resources :news_comments
  map.resources :loads, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/loads"
  map.namespace(:dt) do |dt|
    dt.resource :upowered, :controller => "upowered"
    dt.resources :upowered_email_subscribes, :member => { :unsubscribe => :get }
    dt.resource :search, :controller => 'search', :collection => { :bar => :get }
    dt.resource :search_groups, :controller => 'search_groups'
    dt.resource :cart, :controller => 'cart'
    dt.resource :checkout
    dt.resources :pages do |page|
      page.resources :wall_posts
    end

    dt.resources :projects, :member => { :details => :get,
                                         :community => :get,
                                         :nation => :get,
                                         :organization => :get,
                                         :connect => :get,
                                         :cause => :get,
                                         :facebook_login => :get,
                                         :timeline => :get,
                                         :give => :get},
                            :collection => {  :search => :get,
                                              :advancedsearch => :get,
                                              :add_countries => :get,
                                              :add_causes => :get,
                                              :list => :get,
                                              :pending_projects => :get,
                                              :get_videos => :get
                                          }
    dt.resources :investments, :controller => 'investments'
    dt.resources :place_searches, :controller => 'place_searches'
    #dt.resources :my_wishlists, :controller => 'my_wishlists'
    dt.resources :accounts, :controller => 'accounts', :collection => { :activate => :get, :resend => :get, :reset => :get, :reset_password => :put } do |account|
      account.resources :deposits, :controller => 'deposits'
      account.resources :my_wishlists, :controller => 'my_wishlists', :collection => {:new_message => :get, :confirm => :post, :preview => :get, :send_message => :post}
      account.resources :tax_receipts, :controller => 'tax_receipts'
      account.resources :account_memberships, :controller => 'account_memberships'
    end
    dt.resource :session, :controller => 'sessions'
    dt.resources :gifts, :controller => 'gifts', :collection => { :open => :get, :preview => :get }, :member => { :unwrap => :get }
    dt.resource :email_upload, :controller => 'email_uploads'
    dt.resources :groups, :controller=> 'groups' do |groups|
      groups.resources :memberships, :controller => 'groups/memberships', :member => { :promote => :put, :demote => :put }
      groups.resources :group_projects, :controller => 'group_projects'
      groups.resources :invitations, :controller => 'invitations'
      groups.resources :messages, :controller => 'groups/news'
      groups.resources :wall_messages, :controller => 'groups/wall_messages'
    end
    dt.resources :wishlists, :controller=> 'wishlists'
    dt.resources :tell_friends, :controller=> 'tell_friends', :collection => { :confirm => :post, :preview => :get }
    dt.resources :mdgs, :controller=> 'mdgs'
    
    dt.resource :staff, :controller => 'staff'
    dt.resources :wall_posts

    dt.resources :news_items
    dt.resources :news_items do |news_items|
       news_items.resources :news_comments
     end

    # Campaign System
    dt.resources :campaigns,  :collection => {          :update_address_details_for_country => :post,
                                                        :update_team_config_options => :post,
                                                        :admin => :get,
                                                        :search => :get
                                                        },
                                      :new => {
                                        :validate_short_name_of => :post
                                      },
                                      :member => {      :activate => :post,
                                                        :manage => :get,
                                                        :configure_filters_for => :get,
                                                        :add_project_limit_to => :post,
                                                        :remove_project_limit_from => :post,
                                                        :add_place_limit_to => :post,
                                                        :remove_place_limit_from => :post,
                                                        :add_cause_limit_to => :post,
                                                        :remove_cause_limit_from => :post,
                                                        :add_partner_limit_to => :post,
                                                        :remove_partner_limit_from => :post,
                                                        :join => :get,
                                                        :join_options => :get
                                      }


    dt.resources :teams,  :collection => {  :manage => :get,
                                            :admin => :get
                                           },
                          :new => {
                                        :validate_short_name_of => :post
                          },
                          :member => {  :join => :get,
                                        :approve => :get,
                                        :manage => :get,
                                        :leave => :get
                                      }

    dt.resources :pledges

    dt.resources :participants,
                          :collection => { :admin => :get},
                          :member => { :manage => :get,
                                       :approve => :get,
                                       :decline => :get
                                    },
                          :new => { :validate_short_name_of => :post}

    dt.resources :campaigns do |campaigns|
     campaigns.resources :wall_posts
     campaigns.resources :news_items
     campaigns.resources :teams
     campaigns.resources :participants
     campaigns.resources :pledges
    end

    dt.resources :teams,  :collection => { :manage => :get
                                           },
                          :new => {
                                        :validate_short_name_of => :post
                          },
                          :member => {  :join => :get,
                                        :approve => :get
                                      }

    dt.resources :teams do |teams|
        teams.resources :wall_posts
        teams.resources :news_items
        teams.resources :participants
        teams.resources :pledges
    end

    dt.resources :participants do |participants|
      participants.resources :wall_posts
      participants.resources :news_items
      participants.resources :pledges
    end

    #Done with everything pretaining to campaigns

    dt.resources :give, :controller => 'give'
  end

  map.change_campaign_display_panel '/dt/campaigns/:id/change_panel/:panel', :controller => 'dt/campaigns', :action => 'change_display_panel'
  map.dt_tax_receipt '/dt/tax_receipts/:id/:code', :controller => 'dt/tax_receipts', :action => "show"
  map.dt_signup '/dt/signup', :controller => 'dt/accounts', :action => 'new'
  map.dt_login  '/dt/login',  :controller => 'dt/sessions', :action => 'new'
  map.dt_logout '/dt/logout', :controller => 'dt/sessions', :action => 'destroy'
  map.dt_request_us_tax_receipt '/dt/request_us_tax_receipt', :controller => 'dt/sessions', :action => 'request_us_tax_receipt'


  map.connect '/dt', :controller => 'dt/home'
  map.connect 'dt/campaigns/:id/close', :controller => 'dt/campaigns', :action => 'close'
  map.connect 'dt/participants/:id/activate', :controller => 'dt/participants', :action => 'activate'

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
  map.resources :reports, :path_prefix => "/bus_admin", :controller => "bus_admin/reports"
  map.process_report 'bus_admin/reports/process_report', :controller => 'bus_admin/reports', :action => 'process_report'
  map.resources :deposits, :path_prefix => "/bus_admin", :controller => "bus_admin/deposits"
  map.csv_import 'bus_admin/group_gifts/csv_import', :controller => 'bus_admin/group_gifts', :action => 'csv_import'
  map.resources :group_gifts,  :path_prefix => "/bus_admin", :controller => "bus_admin/group_gifts"
  map.resources :expired_gifts,  :path_prefix => "/bus_admin", :controller => "bus_admin/expired_gifts", :collection => {:unwrap => :post}
  map.resources :unallocated_investments,  :path_prefix => "/bus_admin", :controller => "bus_admin/unallocated_investments", :collection => {:unallocate => :post}
  map.resources :banner_images, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/banner_images"
  map.resources :rank_values, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/rank_values"
  map.resources :load,  :path_prefix => "/bus_admin", :controller => "bus_admin/load", :collection => {:loads => :post}
  map.resources :gifts, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/gifts", :collection => {:change_email => :post}
  map.resources :loads,  :path_prefix => "/bus_admin", :controller => "bus_admin/loads", :collection => {:loads => :post}
  map.resources :sent,  :path_prefix => "/bus_admin", :controller => "bus_admin/sent"
  map.resources :add_to_group,  :path_prefix => "/bus_admin", :controller => "bus_admin/add_to_group", :collection => {:add_to_groups => :post}
  map.resources :budget_items, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/budget_items"
  map.resources :financial_sources, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/financial_sources"
  map.resources :collaborating_agencies, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/collaborating_agencies"
  map.resources :e_cards, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/e_cards"
  map.resources :promotions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/promotions"
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
  map.resources :key_measure_datas, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/key_measure_datas"
  map.add_measure 'bus_admin/key_measures/add_measure', :controller => 'bus_admin/key_measures', :action => 'add_measure'

  map.resources :bus_security_levels, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_security_levels"
  map.resources :bus_user_types, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_user_types"
  map.resources :bus_secure_actions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_secure_actions"
  map.resources :bus_security_levels, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/bus_security_levels"
  map.resources :users, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/users"
  map.resources :roles, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/roles"
  map.resources :administrations, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/administrations"
  map.resources :collaborations, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/collaborations"
  map.resources :permissions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/permissions"
  map.resources :authorized_actions, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/authorized_actions"
  map.resources :authorized_controllers, :active_scaffold => true, :path_prefix => "/bus_admin", :controller => "bus_admin/authorized_controllers"
  # bus_admin project resources and routes
  map.resources :projects, 
                :path_prefix => "/bus_admin", 
                :name_prefix => 'bus_admin_', 
                :controller => 'bus_admin/projects',
                :active_scaffold => true,
                :collection => { :pending_projects => :get}

  map.resource :upowered, :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :controller => "bus_admin/upowered", :member => { :report => :post, :send_email => :post }
  map.resources :subscriptions, :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :controller => "bus_admin/subscriptions"
  map.resources :statistic_widgets, :active_scaffold => true, :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :controller => "bus_admin/statistic_widgets"
  map.resources :pages, :controller => "bus_admin/pages", :name_prefix => 'bus_admin_', :path_prefix => "/bus_admin", :active_scaffold => true


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
  map.resources :place_you_tube_videos, :path_prefix => "/bus_admin",
    :controller => "bus_admin/place_you_tube_videos",
    :collection => { :add => :post, :remove => :post, :search => :post, :places => :post, :videos => :post,:preview => :post, :search_by_tag => :post, :search_by_user => :post, :search_by_category_and_tag => :post, :list_by_featured => :post, :list_by_popular => :post, :show_video => :post, :list => :get }
  map.resources :project_you_tube_videos, :path_prefix => "/bus_admin",
    :controller => "bus_admin/project_you_tube_videos",
    :collection => { :add => :post, :remove => :post, :search => :post, :projects => :post, :videos => :post, :preview => :post, :search_by_tag => :post, :search_by_user => :post, :search_by_category_and_tag => :post, :list_by_featured => :post, :list_by_popular => :post, :show_video => :post, :show_search => :get, :update_table => :post, :row => :get, :list => :get }
  map.resources :place_flickr_images, :path_prefix => "/bus_admin",
    :controller => "bus_admin/place_flickr_images",
    :collection => { :add => :post, :remove => :post, :search => :post, :places => :post, :show_flickr => :post, :show_db_flickr => :post, :photos=>:post, :list => :get }
  map.resources :project_flickr_images, :path_prefix => "/bus_admin",
    :controller => "bus_admin/project_flickr_images",
    :collection => { :add => :post, :remove => :post, :search => :post, :projects => :post, :show_flickr => :post, :show_db_flickr => :post, :photos=>:post, :show_search => :get, :update_table => :post, :row => :get, :list => :get }
  map.resources :welcome, :path_prefix => "/bus_admin", :controller => "bus_admin/welcome"
  map.resources :home, :path_prefix => "/bus_admin", :controller => "bus_admin/home"
  map.home_update_partner 'bus_admin/home/update_partner', :controller => 'bus_admin/home', :action => 'update_partner'

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

  map.resources :programs, :controller => "bus_admin/programs",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :milestones, :controller => "bus_admin/milestones",
    :path_prefix => "/bus_admin", :name_prefix => 'bus_admin_', :active_scaffold => true
  map.resources :tasks, :controller => "bus_admin/tasks",
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
  map.pending_projects 'bus_admin/pending_projects', :controller => 'bus_admin/projects', :action => 'pending_projects'
  map.show_pending_project 'bus_admin/show_pending_projects', :controller => 'bus_admin/projects', :action => 'show_pending_project'
  map.report 'bus_admin/report', :controller => 'bus_admin/projects', :action => 'report'
  map.kpi_report 'bus_admin/_kpi_report', :controller => 'bus_admin/projects', :action => 'kpi_report'
  map.report 'bus_admin/individual_report', :controller => 'bus_admin/projects', :action => 'individual_report'
  map.byProject 'bus_admin/_timeline_json', :controller => 'bus_admin/projects', :action => 'byProject'
  map.showProjectTimeline 'bus_admin/_showProjectTimeline', :controller => 'bus_admin/projects', :action => 'showProjectTimeline'
  map.stats 'bus_admin/stats', :controller => 'bus_admin/stats', :action => 'index'

  map.auto_complete_for_place_name  '/auto_complete_for_place_name', :controller => 'bus_admin/projects', :action => 'auto_complete_for_place_name'
  map.update_location 'bus_admin/_update_location', :controller => 'bus_admin/projects', :action => 'update_location'
  map.update_partner 'bus_admin/_update_partner', :controller => 'bus_admin/projects', :action => 'update_partner'
  map.update_sectors 'bus_admin/_update_sectors', :controller => 'bus_admin/projects', :action => 'update_sectors'
  map.create_subagreement 'bus_admin/_create_subagreement', :controller => 'bus_admin/projects', :action => 'create_subagreement'
  map.delete_pending 'bus_admin/_delete_pending', :controller => 'bus_admin/projects', :action => 'delete_pending'
  map.project_auto_update 'bus_admin/_auto_update', :controller => 'bus_admin/projects', :action => 'auto_update'

  map.report 'bus_admin/report_partners', :controller => 'bus_admin/partners', :action => 'report_partners'
  map.report 'bus_admin/individual_report_partners', :controller => 'bus_admin/partners', :action => 'individual_report_partners'
  map.export_to_csv 'bus_admin/export_to_csv', :controller => 'bus_admin/projects', :action => 'export_to_csv'
  map.resend 'bus_admin/resend', :controller => 'bus_admin/gifts', :action => 'resend'
  map.resend_gift 'bus_admin/resend_gift', :controller => 'bus_admin/gifts', :action => 'resend_gift'

  map.display_inline_report 'bus_admin/display_inline_report', :controller => 'bus_admin/projects', :action => 'display_inline_report'
  map.report 'bus_admin/individual_report_inline', :controller => 'bus_admin/projects', :action => 'individual_report_inline'
  map.note 'bus_admin/show_note', :controller => 'bus_admin/partners', :action => 'show_note'
  map.note_project 'bus_admin/show_project_note', :controller => 'bus_admin/projects', :action => 'show_project_note'
  map.note_program 'bus_admin/show_program_note', :controller => 'bus_admin/programs', :action => 'show_program_note'
  map.reset_password 'bus_admin/reset_password', :controller => 'bus_admin/bus_account', :action => 'reset_password'
  map.reset_password_now 'bus_admin/reset_password_now', :controller => 'bus_admin/bus_account', :action => 'reset_password_now'
  map.request_temporary_password 'bus_admin/request_temporary_password', :controller => 'bus_admin/bus_account', :action => 'request_temporary_password'

  map.pending_projects 'bus_admin/pending_projects', :controller => 'bus_admin/projects', :action => 'pending_projects'

  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect '/bus_admin', :controller => 'bus_admin/home'

  map.show_campaign '/dt/:short_name', :controller => 'dt/campaigns', :action => 'show'
  map.show_campaign_team '/dt/:short_campaign_name/team/:short_name', :controller => 'dt/teams', :action => 'show'
  map.show_campaign_group '/dt/:short_campaign_name/group/:short_name', :controller => 'dt/teams', :action => 'show'
  map.show_campaign_classroom '/dt/:short_campaign_name/classroom/:short_name', :controller => 'dt/teams', :action => 'show'
  map.show_campaign_participant '/dt/:short_campaign_name/team/:team_short_name/participant/:short_name', :controller => 'dt/participants', :action => 'show'
  map.show_campaign_participant '/dt/:short_campaign_name/participant/:short_name', :controller => 'dt/participants', :action => 'show'

  # Install the default route as the lowest priority.
  #map.connect "*anything",
  #            :controller => 'dt/projects'
  # HPD these should not be used / exist when using 'full' RESTful structure
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'

	# TODO: Is this the right way to route the iframe?
	map.connect '/bus_admin/projects/embedded_budget_items/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_budget_items'
	map.connect '/bus_admin/projects/embedded_milestones/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_milestones'
	map.connect '/bus_admin/projects/embedded_key_measures/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_key_measures'
	map.connect '/bus_admin/projects/embedded_you_tube_videos/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_you_tube_videos'
	map.connect '/bus_admin/projects/embedded_collaborations/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_collaborations'
	map.connect '/bus_admin/projects/embedded_flickr_images/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_flickr_images'
	map.connect '/bus_admin/projects/embedded_financial_sources/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_financial_sources'

	map.connect '/bus_admin/places_for_approval', :controller => 'bus_admin/places', :action => 'places_for_approval'

end
