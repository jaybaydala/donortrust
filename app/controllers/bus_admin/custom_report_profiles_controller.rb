class BusAdmin::CustomReportProfilesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    @users = User.find(:all, :include => :profile, :conditions => ['created_at < ?', @end_date])
    @users_created = User.find(:all, :include => :profile, :conditions => ['created_at > ? and created_at < ?', @start_date, @end_date])

    @num_profiles = 0
    @num_profiles_created = 0
    @users.each do |u|
      @num_profiles += 1 if u.profile.present?
    end
    @users_created.each do |u|
      @num_profiles_created += 1 if u.profile.present?
    end

    respond_to do |format|
      format.csv { render_csv("profiles-#{@start_date}-#{@end_date}") }
      format.html
    end
  end
end