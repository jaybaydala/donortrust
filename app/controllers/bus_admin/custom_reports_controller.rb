class BusAdmin::CustomReportsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  def index

  end

end