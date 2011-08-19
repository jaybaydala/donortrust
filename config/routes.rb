ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dt/home', :action => 'index'
  map.namespace(:iend) do |dt|
    dt.resources :users
  end
  map.namespace(:dt) do |dt|
    dt.resources :authentications
    dt.auth_callback "/auth/:provider/callback", :controller => "authentications", :action => "create"
    dt.auth_failure "/auth/failure", :controller => "authentications", :action => "failure"
    dt.resources :accounts, 
      :controller => 'accounts', 
      :collection => { :activate => :get, :resend => :get, :reset => :get, :reset_password => :put },
      :member => { :transactions => :get } do |account|
      account.resources :deposits, :controller => 'deposits'
      account.resources :my_wishlists, :controller => 'my_wishlists', :collection => {:new_message => :get, :confirm => :post, :preview => :get, :send_message => :post}
      account.resources :tax_receipts, :controller => 'tax_receipts'
      account.resources :account_memberships, :controller => 'account_memberships'
    end
    dt.resources :deposits, :controller => 'deposits'
    dt.resources :users, :member => { :edit_password => :get }
    dt.resources :facebook_posts
    dt.resource :session, :controller => 'sessions'

    dt.resource :upowered, :controller => "upowered"
    dt.resources :upowered_email_subscribes, :member => { :unsubscribe => :get }
    dt.resource :christmasfuture, :controller => 'christmasfuture'
    dt.resource :support_badges, :controller => 'support_badges'
    dt.resource :search, :controller => 'search', :collection => { :bar => :get }
    dt.resource :search_groups, :controller => 'search_groups'
    dt.resource :cart, :controller => 'cart' do |cart|
      cart.resource :donation
    end
    dt.resource :checkout
    dt.resources :subscriptions
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
    dt.resources :gifts, :controller => 'gifts', :collection => { :open => :get, :preview => :get, :match => :put }, :member => { :unwrap => :get }
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
    dt.resources :campaigns, :collection => { :update_address_details_for_country => :post,
                                              :update_team_config_options => :post,
                                              :admin => :get,
                                              :search => :get },
                             :new =>        { :validate_short_name_of => :post },
                             :member =>     { :activate => :post,
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
                                              :join_options => :get } do |campaigns|
      campaigns.resources :wall_posts
      campaigns.resources :news_items
      campaigns.resources :teams
      campaigns.resources :participants
      campaigns.resources :pledges
    end


    dt.resources :teams,  :collection =>  { :manage => :get,
                                            :admin => :get },
                          :new =>         { :validate_short_name_of => :post },
                          :member =>      { :join => :get,
                                            :approve => :get,
                                            :manage => :get,
                                            :leave => :get } do |teams|
        teams.resources :wall_posts
        teams.resources :news_items
        teams.resources :participants
        teams.resources :pledges
    end

    dt.resources :pledges

    dt.resources :participants, :collection => { :admin => :get },
                                :member =>     { :manage => :get,
                                                 :approve => :get,
                                                 :decline => :get },
                                :new => { :validate_short_name_of => :post} do |participants|
      participants.resources :wall_posts
      participants.resources :news_items
      participants.resources :pledges
    end

    #Done with everything pretaining to campaigns

    dt.resource :give, :controller => 'give'
    
    # User campaign profiles
    dt.resources :profiles, :only => 'show', :member => { :increase_gifts => :get,
                                                          :decrease_gifts => :get,
                                                          :request_gift => :get }
  end

  map.resources :news_comments

  map.change_campaign_display_panel '/dt/campaigns/:id/change_panel/:panel', :controller => 'dt/campaigns', :action => 'change_display_panel'
  map.dt_tax_receipt '/dt/tax_receipts/:id/:code.:format', :controller => 'dt/tax_receipts', :action => "show"
  map.dt_signup '/dt/signup', :controller => 'dt/accounts', :action => 'new'
  map.dt_login  '/dt/login',  :controller => 'dt/sessions', :action => 'new'
  map.dt_logout '/dt/logout', :controller => 'dt/sessions', :action => 'destroy'
  map.dt_home  '/dt/home',  :controller => 'dt/home'
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


  map.namespace :bus_admin do |ba|
    ba.resources :content_snippets, :active_scaffold => true
    ba.resources :loads, :active_scaffold => true
    ba.resources :reports
    ba.resources :deposits
    ba.resources :group_gifts
    ba.resources :expired_gifts, :collection => {:unwrap => :post}
    ba.resources :unallocated_investments, :collection => {:unallocate => :post}
    ba.resources :banner_images, :active_scaffold => true
    ba.resources :rank_values, :active_scaffold => true
    ba.resources :load, :controller => "bus_admin/load", :collection => {:loads => :post}
    ba.resources :gifts, :active_scaffold => true, :collection => {:change_email => :post}
    ba.resources :loads, :collection => {:loads => :post}
    ba.resources :sent, :controller => "bus_admin/sent"
    ba.resources :add_to_group, :controller => "bus_admin/add_to_group", :collection => {:add_to_groups => :post}
    ba.resources :budget_items, :active_scaffold => true
    ba.resources :financial_sources, :active_scaffold => true
    ba.resources :collaborating_agencies, :active_scaffold => true
    ba.resources :e_cards, :active_scaffold => true
    ba.resources :promotions, :active_scaffold => true
    ba.resources :place_sectors, :active_scaffold => true
    ba.resources :ranks, :active_scaffold => true
    ba.resources :quick_fact_partners, :active_scaffold => true
    ba.resources :quick_fact_groups, :active_scaffold => true
    ba.resources :quick_fact_sectors, :active_scaffold => true
    ba.resources :quick_fact_places, :active_scaffold => true
    ba.resources :quick_facts, :active_scaffold => true
    ba.resources :comments, :active_scaffold => true

    ba.resources :key_measures, :active_scaffold => true
    ba.resources :key_measure_datas, :active_scaffold => true

    ba.resources :bus_security_levels, :active_scaffold => true
    ba.resources :bus_user_types, :active_scaffold => true
    ba.resources :bus_secure_actions, :active_scaffold => true
    ba.resources :bus_security_levels, :active_scaffold => true
    ba.resources :users, :active_scaffold => true, :member => { :sudo => :put }
    ba.resources :roles, :active_scaffold => true
    ba.resources :administrations, :active_scaffold => true
    ba.resources :collaborations, :active_scaffold => true
    ba.resources :carousel_items, :active_scaffold => true
    ba.resources :permissions, :active_scaffold => true
    ba.resources :authorized_actions, :active_scaffold => true
    ba.resources :authorized_controllers, :active_scaffold => true
    # bus_admin project resources and routes
    ba.resources :projects, 
                  :controller => 'bus_admin/projects',
                  :active_scaffold => true,
                  :collection => { :pending_projects => :get}

    ba.resource :upowered, :member => { :report => :post, :send_email => :post }
    ba.resources :application_settings, :active_scaffold => true
    ba.resources :subscriptions
    ba.resources :statistic_widgets, :active_scaffold => true
    ba.resources :pages, :active_scaffold => true


    # The priority is based upon order of creation: first created -> highest priority.

    #
    # RSS Feed Resources
    #
    ba.resources :rss
    ba.resources :rss_feed_elements, :active_scaffold => true
    ba.resources :rss_feeds, :active_scaffold => true

    #
    # Media Resources Specifically You Tube and Flickr Resources
    #
    #
    # take that REST
    ba.resources :place_you_tube_videos, :active_scaffold => true,
      :collection => { :add => :post, :remove => :post, :search => :post, :places => :post, :videos => :post,:preview => :post, :search_by_tag => :post, :search_by_user => :post, :search_by_category_and_tag => :post, :list_by_featured => :post, :list_by_popular => :post, :show_video => :post, :list => :get }
    ba.resources :project_you_tube_videos, :active_scaffold => true,
      :collection => { :add => :post, :remove => :post, :search => :post, :projects => :post, :videos => :post, :preview => :post, :search_by_tag => :post, :search_by_user => :post, :search_by_category_and_tag => :post, :list_by_featured => :post, :list_by_popular => :post, :show_video => :post, :show_search => :get, :update_table => :post, :row => :get, :list => :get }
    ba.resources :place_flickr_images, :active_scaffold => true,
      :collection => { :add => :post, :remove => :post, :search => :post, :places => :post, :show_flickr => :post, :show_db_flickr => :post, :photos=>:post, :list => :get }
    ba.resources :project_flickr_images, :active_scaffold => true, :member => {:delete => :delete}, 
      :collection => { :add => :post, :remove => :post, :search => :post, :projects => :post, :show_flickr => :post, :show_db_flickr => :post, :photos=>:post, :show_search => :get, :update_table => :post, :row => :get, :list => :get }
    ba.resources :welcome, :controller => "bus_admin/welcome"
    ba.resources :home, :controller => "bus_admin/home"

    ba.resources :measures, :active_scaffold => true

    ba.resources :millennium_goals, :active_scaffold => true
    ba.resources :sectors, :active_scaffold => true
    ba.resources :causes, :active_scaffold => true

    #
    # Geographical Resources
    #
    ba.resources :places, :active_scaffold => true

    #
    # Contacts
    #
    ba.resources :contacts, :active_scaffold => true
    ba.resources :partners, :active_scaffold => true

    #
    # Campaigns
    #
    ba.resources :campaigns, :active_scaffold => true, :member => { :close => :put }
    ba.resources :teams, :active_scaffold => true
    ba.resources :participants, :active_scaffold => true
    ba.resources :campaign_types, :active_scaffold => true
    ba.resources :cause_limits, :active_scaffold => true
    ba.resources :place_limits, :active_scaffold => true
    ba.resources :partner_limits, :active_scaffold => true

    #
    # Gather normal 'lookup' resources together.  Standard RESTful resources, no nesting
    #
    ba.resources :project_statuses, :active_scaffold => true
    ba.resources :milestone_statuses, :active_scaffold => true
    ba.resources :frequency_types, :active_scaffold => true
    ba.resources :partner_statuses, :active_scaffold => true
    ba.resources :partner_types, :active_scaffold => true
    ba.resources :group_types, :active_scaffold => true
    ba.resources :place_types, :active_scaffold => true
    ba.resources :rank_types, :active_scaffold => true
    ba.resources :quick_fact_types, :active_scaffold => true

    ba.resources :programs, :active_scaffold => true
    ba.resources :milestones, :active_scaffold => true
    ba.resources :tasks, :active_scaffold => true
    ba.resources :measures
    ba.resources :accounts, :active_scaffold => true
    ba.resources :groups, :active_scaffold => true
    ba.resources :bus_account, :active_scaffold => true, :controller => "bus_admin/bus_account"
  end

  map.recover_record 'bus_admin/causes/recover_record', :controller => 'bus_admin/causes', :action => 'recover_record'
  map.process_report 'bus_admin/reports/process_report', :controller => 'bus_admin/reports', :action => 'process_report'
  map.csv_import 'bus_admin/group_gifts/csv_import', :controller => 'bus_admin/group_gifts', :action => 'csv_import'
  map.populate_project_places '/bus_admin/projects/populate_project_places', :controller => 'bus_admin/projects', :action => 'populate_project_places'
  map.feedback 'bus_admin/feedback', :controller => 'bus_admin/comments', :action => 'feedback'
  map.add_measure 'bus_admin/key_measures/add_measure', :controller => 'bus_admin/key_measures', :action => 'add_measure'
  map.home_update_partner 'bus_admin/home/update_partner', :controller => 'bus_admin/home', :action => 'update_partner'
  map.populate_contact_places '/bus_admin/contacts/populate_contact_places', :controller => 'bus_admin/contacts', :action => 'populate_contact_places'
  map.populate_project_places '/bus_admin/projects/populate_project_places', :controller => 'bus_admin/projects', :action => 'populate_project_places'
  map.populate_place_sector_places '/bus_admin/projects/populate_place_sector_places', :controller => 'bus_admin/place_sectors', :action => 'populate_place_sector_places'


  #easier routes for restful_authentication
  map.bob '/bus_admin/bob', :controller => 'bus_admin/project_statuses', :action => 'bob'
  map.signup '/bus_admin/signup', :controller => 'bus_admin/bus_account', :action => 'signup'
  map.login '/bus_admin/login', :controller => 'bus_admin/bus_account', :action => 'login'
  map.logout '/bus_admin/logout', :controller => 'bus_admin/bus_account', :action => 'logout'
  map.index '/bus_admin/index', :controller => 'bus_admin/bus_account', :action => 'index'
  map.get_actions '/bus_admin/bus_user_types/get_actions', :controller => 'bus_admin/bus_user_types', :action =>'get_actions'
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

	# TODO: Is this the right way to route the iframe?
	map.connect '/bus_admin/projects/embedded_budget_items/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_budget_items'
	map.connect '/bus_admin/projects/embedded_milestones/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_milestones'
	map.connect '/bus_admin/projects/embedded_key_measures/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_key_measures'
	map.connect '/bus_admin/projects/embedded_you_tube_videos/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_you_tube_videos'
	map.connect '/bus_admin/projects/embedded_collaborations/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_collaborations'
	map.connect '/bus_admin/projects/embedded_flickr_images/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_flickr_images'
	map.connect '/bus_admin/projects/embedded_financial_sources/:project_id', :controller => 'bus_admin/projects', :action => 'embedded_financial_sources'

	map.connect '/bus_admin/places_for_approval', :controller => 'bus_admin/places', :action => 'places_for_approval'

  map.connect "*path", :controller => 'dt/pages', :action => "show"
end
