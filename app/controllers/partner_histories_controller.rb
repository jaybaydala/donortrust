class PartnerHistoriesController < ApplicationController
  active_scaffold do |config|
    config.actions.exclude :create
    config.actions.exclude :delete
    config.actions.exclude :update
    config.actions.exclude :nested
  end
end
