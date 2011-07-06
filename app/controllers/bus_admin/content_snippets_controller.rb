class BusAdmin::ContentSnippetsController < ApplicationController
  layout 'admin'
  
  active_scaffold :content_snippet do |config|
    config.columns = [ :title, :slug, :body, :active ]
    config.list.columns = [ :title, :slug, :active ]
  end
end