class BusAdmin::QuickFactTypesController < ApplicationController

  active_scaffold :quick_fact_types do |config|
    config.columns = [:name, :description ]
  end

end
