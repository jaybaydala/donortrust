class BusAdmin::AccountsController < ApplicationController

  active_scaffold :accounts do |config|
    config.columns = [:fullname, :city, :state, :country, :email, :last_logged_in ]
    list.columns.exclude [:last_logged_in]
    update.columns.exclude [:last_logged_in]
    config.columns[ :state ].label = "Region"
    config.columns[:fullname].label = "Name"
    config.label = "Donor Accounts"
    config.actions.exclude :create
  end

end
