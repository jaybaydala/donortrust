class Dt::GroupsController < DtApplicationController
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :load_membership, :except => [ :index, :new, :create ]
  helper 'dt/places'
  helper_method :current_member
  
  def initialize
    @topnav = 'get_involved'
  end

  def index
    @groups = Group.find :all, :conditions => {:featured => :true, :private => :false}
    @groups = Group.find :all, :conditions => {:private => :false} if @groups.empty?
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def show
    @group = Group.find(params[:id])
    @membership = Membership.find_by_user_id(current_user, :conditions => { :group_id => params[:id] })
    respond_to do |format|
      if @group.private && !@membership
        format.html { redirect_to :action => :index }
      else
        format.html
      end
    end
  end

  def new
    @group = Group.new
    @sectors = Sector.find(:all)
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])
    Group.transaction do
      group_saved = @group.valid? && @group.save!
      membership_saved = @group.memberships.create({ :user_id => current_user.id, :membership_type => Membership.founder })
      @saved = group_saved && membership_saved
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        flash[:notice] = 'Group and membership was successfully created.'
        format.html { redirect_to dt_group_path(@group) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @group = Group.find(params[:id])
    @saved = @group.update_attributes(params[:group])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to dt_group_path(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to dt_groups_url }
      format.xml  { head :ok }
    end
  end
  
  protected
  def current_member(group = nil, user = current_user)
    group ||= Group.find(params[:id])
    @current_member ||= group.memberships.find_by_user_id(user) if user
  end

  def load_membership
    return if params[:id].nil? || params[:id].empty?
    @membership = Membership.find_by_user_id(current_user, :conditions => { :group_id => params[:id] })
  end
  
  # protect the show/edit/update methods so you can only update/view your own record
  def authorized?(user = current_user())
    if ['new', 'create'].include?(action_name)
      return false unless logged_in?
    end
    if ['edit', 'update'].include?(action_name)
      return false unless logged_in? && current_member && current_member.membership_type >= Membership.admin
    end
    if ['destroy'].include?(action_name)
      return false unless logged_in? && current_member && current_member.membership_type >= Membership.founder
    end
    return true
  end

  def access_denied
    if ['new', 'create'].include?(action_name) 
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    end
    if ['edit', 'update', 'destroy'].include?(action_name) && logged_in?
      respond_to do |accepts|
        accepts.html { redirect_to( :controller => '/dt/groups', :action => 'show', :id => params[:id]) and return }
      end
    end
    super
  end
end
