class BusAdmin::FeedbacksController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold :feedback do |config|
    config.actions.exclude :create, :delete
    update.columns.exclude [ :user ]
    config.list.columns = [:resolved, :name, :email, :created_at, :subject, :message]
    config.show.columns = [:resolved, :name, :email, :created_at, :subject, :message]
  end
  
  verify :method => :post, :only => [ :destroy, :create ], :redirect_to => { :action => :list }
  verify :method => :put, :only => [ :update ], :redirect_to => { :action => :list }
end
