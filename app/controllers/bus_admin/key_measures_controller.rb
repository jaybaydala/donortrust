class BusAdmin::KeyMeasuresController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  active_scaffold :key_measures do |config|
    config.actions = [ :create, :update, :delete, :list, :nested, :subform ]
    
    config.columns = [ :measure, :project, :target,  :key_measure_datas, :millennium_goals, :decrease_target]   
    config.nested.add_link("Measurements Data", [:key_measure_datas])
    list.columns.exclude [:key_measure_datas, :millennium_goals , :decrease_target]
    update.columns.exclude [  :key_measure_datas ]
    create.columns.exclude [ :key_measure_datas ]
    config.columns[ :measure ].form_ui = :select
    config.columns[ :project ].form_ui = :select
    config.columns[ :millennium_goals ].form_ui = :select
  end  
end
