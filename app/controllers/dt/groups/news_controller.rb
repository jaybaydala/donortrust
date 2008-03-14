class Dt::Groups::NewsController < DtApplicationController
  include GroupPermissions
  helper "dt/groups"
  helper_method :news_allowed?
  before_filter :membership_required_if_private_group, :only => 'index'
  before_filter :admin_required, :except => 'index'
  
  def initialize
    @topnav = 'get_involved'
    @page_title = "Group News"
  end

  def index
    @group = Group.find(params[:group_id])
    @group_message = @group.news.build
    @group_messages = @group.news.paginate({:page => params[:page], :per_page => 5, :order => "created_at DESC"})
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @group = Group.find(params[:group_id])
    @group_news = @group.news.build({:user => current_user})
  end
  
  def create
    @group = Group.find(params[:group_id])
    @group_news = @group.news.build(params[:group_message].merge({:user => current_user}))
    @saved = @group_news.save
    respond_to do |format|
      if @saved
        flash[:notice] = "Your message has been added successfully."
        format.html{redirect_to dt_group_path(@group)}
      else
        format.html{render :action => 'new'}
      end
    end
  end
  
  def edit
    @group = Group.find(params[:group_id])
    @group_news = @group.news.find(params[:id])
    @member = @group.memberships.find_by_user_id(current_user.id)
    respond_to do |format|
      unless news_allowed?
        format.html{redirect_to dt_group_path(@group)}
      else
        format.html
      end
    end
  end
  
  def update
    @group = Group.find(params[:group_id])
    @group_news = @group.news.find(params[:id])
    @group_news.user = current_user
    @member = @group.memberships.find_by_user_id(current_user.id)
    respond_to do |format|
      unless news_allowed?
        format.html{redirect_to dt_group_path(@group)}
      else
        if @group_news.update_attributes(params[:group_news])
          format.html{redirect_to dt_group_path(@group)}
        else
          format.html{render :action => "edit"}
        end
      end
    end
  end
  
  def destroy
    @group = Group.find(params[:group_id])
    @group_news = @group.news.find(params[:id])
    @member = @group.memberships.find_by_user_id(current_user.id)
    respond_to do |format|
      unless news_allowed?
        format.html{redirect_to dt_group_path(@group)}
      else
        flash[:notice] = @group_news.destroy ? 
          "Your Group News message has been destroyed" : 
          "Your Group News message could not be deleted"
        format.html{redirect_to dt_messages_path(@group)}
      end
    end
  end
  
  protected
  def news_allowed?(group_news_id=nil)
    return false unless logged_in?
    @member = @group.memberships.find_by_user_id(current_user.id)
    return false if !@member.admin?
    return true if @member.founder?
    group_news = group_news_id.nil? ? @group_news : GroupNews.find(group_news_id)
    return true if @member.admin? && group_news.new_record?
    return true if @member.admin? && @member.user_id == group_news.user_id
    false
  end
end