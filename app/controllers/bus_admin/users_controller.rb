class BusAdmin::UsersController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin' 
  include BusAdmin::UsersHelper
  include UploadSyncHelper
  after_filter :sync_uploads, :only => [:create, :update, :destroy]
   
  active_scaffold do |config|
    config.columns = [ :first_name, :last_name, :login, :country, :roles, :staff, :title, :twitter, :facebook, :bio]
    config.columns[:roles].form_ui = :select 
    config.list.columns = [:first_name, :last_name, :login, :roles, :staff]
    config.update.columns = [:first_name, :last_name, :login, :display_name, :address,  :city, :province, :country, :postal_code, :administrations, :staff, :title, :twitter, :facebook, :bio]
    config.columns[:administrations].label = "Roles"    
    config.action_links.add(:sudo, { :label => "Become", :method => :put, :crud_type => :update, :type => :record, :inline => false })
  end

 def sudo
   if current_user.superuser?
     @user = User.find(params[:id])
     session[:user] = @user.id
     current_user = @user
     cookies[:login_id] = @user.id.to_s
     cookies[:login_name] = @user.full_name
     flash[:notice] = "You are now acting as #{current_user.login}. You'll need to logout and log back in as yourself to change back"
     redirect_to(:controller => '/dt/home', :action => 'index')
   else
     flash[:notice] = "Sorry, only superusers can do that."
     redirect_to users_path
   end
 end
end
