class BusAdmin::UploadsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  active_scaffold :uploads do |config|
    config.label = "Contacts"
    config.list.columns = [:title, :file]
    config.update.columns = [:title, :file]
    config.create.columns = [:title, :file]
    config.show.columns = [:title, :file]

    # config.columns[:file].form_ui = :file
  end
end