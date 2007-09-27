class BusAdmin::QuickFactsController < ApplicationController

 active_scaffold :quick_facts do |config|
    config.columns = [:name, :description, :quick_fact_type ]
    config.columns[ :quick_fact_type ].form_ui = :select
  end
end