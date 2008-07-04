class BusAdmin::AdministrationsController < ApplicationController
  layout 'admin'
  
  active_scaffold do |config|
    config.columns = [:role, :user]
    config.columns[:role].form_ui = :select
    config.columns[:user].form_ui = :select
  end
end
