class BusAdmin::ApplicationSettingsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  active_scaffold do |config|
    config.list.columns = [:name, :slug, :value]
    config.create.columns = [:name, :slug, :value]
    config.update.columns = [:name, :slug, :value]
  end

end