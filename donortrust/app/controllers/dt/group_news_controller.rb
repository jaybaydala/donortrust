class Dt::GroupNewsController < DtApplicationController
  before_filter :login_required

  def index
    @recent_group_news = GroupNews.find :all, :conditions => { :group_id => params[:group_id] }
  end
end