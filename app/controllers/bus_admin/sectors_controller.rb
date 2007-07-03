class BusAdmin::SectorsController < ApplicationController
  before_filter :login_required

  active_scaffold :sectors do |config|
    config.columns =[ :name, :description ]
  end
end
