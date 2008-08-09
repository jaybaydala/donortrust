class BusAdmin::GroupsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin' 


  active_scaffold :groups do |config|
    config.columns = [:name, :group_type, :private, :featured, :description, :created_at, :updated_at, :project_count, :projects, :user_count, :users ]
    # unable to select user(s) to add to group by simply adding :users to column.  Even though the relationship is defined as
    # has_many :users, :through => :memberships
    # the active scaffold code is generating SQL like:
    # SELECT * FROM users WHERE (group_id IS NULL)
    # which fails because there is no group_id field in the users table.  It is in memberships.
    config.columns[ :group_type ].form_ui = :select
    config.columns[ :group_type ].label = "Type"
    config.columns[ :featured ].label = "Is Featured?"
    config.columns[ :projects ].form_ui = :select
    config.columns[ :users ].form_ui = :select
    list.columns.exclude [ :description, :created_at, :updated_at, :project_count, :projects, :user_count, :users ]
    update.columns.exclude [ :created_at, :updated_at, :project_count, :user_count, :users ]
    create.columns.exclude [ :created_at, :updated_at, :project_count, :user_count, :users ]
    #show.columns.exclude [  ]
  end

end
