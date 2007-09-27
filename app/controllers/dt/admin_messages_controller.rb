class Dt::AdminMessagesController < DtApplicationController
  before_filter :login_required

  def index
    @recent_admin_messages = AdminMessage.find :all, :conditions => { :group_id => params[:group_id] }
  end
end